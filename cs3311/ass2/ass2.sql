-- COMP3311 20T3 Assignment 2

-- Q1: students who've studied many courses

create view Q1(unswid,name)
as
   select p.unswid, p.name
   from   Students s
      join  People p on (s.id = p.id)
      join  Course_enrolments c on (c.student = p.id)
   group by p.id
   having   count(p.id) > 65
;

-- Q2: numbers of students, staff and both

create or replace view Q2(nstudents,nstaff,nboth)
as
   with  
      stu as ((select id from Students) except (select id from Staff)),
      sta as ((select id from Staff) except (select id from Students)),
      stuAndsta as ((select id from Staff) intersect (select id from Students))
   select
      (select count(*) from stu) as nstudents,
      (select count(*) from sta) as nstaff,
      (select count(*) from stuAndsta) as nboth
;
-- Q3: prolific Course Convenor(s)

create or replace view Q3(name,ncourses)
as
   with tmp as (
      select p.name as name, count(p.name) as ncourses
      from  Staff s
         join People p on (s.id = p.id)
         join Course_staff c on (c.staff = s.id)
         join Staff_roles r on (c.role = r.id)
      where r.name = 'Course Convenor'
      group by p.name
   )
   select name, ncourses
   from tmp
   where ncourses = (select max(ncourses) from tmp)
;

-- Q4: Comp Sci students in 05s2 and 17s1

create or replace view Q4a(id,name)
as
   select p.unswid, p.name
   from  People p
      join Students s on (s.id = p.id)
      join Program_enrolments e on (e.student = s.id)
      join Programs prog on (prog.id = e.program)
      join Terms t on (t.id = e.term)
   where t.name = 'Sem2 2005' and prog.code = '3978'
;

create or replace view Q4b(id,name)
as
   select p.unswid, p.name
   from  People p
      join Students s on (s.id = p.id)
      join Program_enrolments e on (e.student = s.id)
      join Programs prog on (prog.id = e.program)
      join Terms t on (t.id = e.term)
   where t.name = 'Sem1 2017' and prog.code = '3778'
;

-- Q5: most "committee"d faculty

create or replace view Q5(name)
as
   with tmp as (
      select facultyof(o.id) as orgid, count(o.id) as norgs
      from  OrgUnits o
         join OrgUnit_types t on (o.utype = t.id)
      where t.name = 'Committee' and facultyof(o.id) is not null
      group by orgid
   )
   select o.name
   from  OrgUnits o
      join tmp t on (o.id = t.orgid)
   where t.norgs = (select max(norgs) from tmp)
;

-- Q6: nameOf function

create or replace function
   Q6(_id integer) returns text
as $$
   (select p.name from People p where p.id = _id)
   union
   (select p.name from People p where p.unswid = _id)
$$ language sql;

-- Q7: offerings of a subject

create or replace function
   Q7(_subject text)
     returns table (subject text, term text, convenor text)
as $$
   select   sub.code :: text, termname(t.id), p.name
   from     Subjects sub
      join  Courses c on (c.subject = sub.id)
      join  Course_staff sta on (sta.course = c.id)
      join  Staff s on (sta.staff = s.id)
      join  People p on (s.id = p.id)
      join  Staff_roles r on (r.id = sta.role)
      join  Terms t on (t.id = c.term)
   where    r.name = 'Course Convenor' and sub.code = _subject
$$ language sql;

-- Q8: transcript

create or replace function
   Q8(zid integer) returns setof TranscriptRecord
as $$
   declare
      result TranscriptRecord;
      tup record;
      totalUOCattempted float;
      weightedSumOfMarks float;
      UOCpassed integer;
   begin
      totalUOCattempted := 0;
      weightedSumOfMarks := 0;
      UOCpassed := 0;
      if not exists (select * from students s 
                     join  People p on (s.id = p.id)
                     where p.unswid = zid)
      then raise exception 'Invalid student %', zid;
      end if;
      for tup in
         select
            s.code as code, t.id as term, prog.code as prog,
            s.name as name, ce.mark as mark, ce.grade as grade,
            s.uoc as uoc
         from  Course_enrolments ce
               join  Courses c on (c.id = ce.course)
               join  Subjects s on (s.id = c.subject)
               join  Terms t on (c.term = t.id)
               join  People stu on (stu.id = ce.student)
               join  Program_enrolments pe on (stu.id = pe.student and pe.term = t.id)
               join  Programs prog on (pe.program = prog.id)
         where stu.unswid = zid
      loop
         result.code := tup.code;
         result.term := termName(tup.term);
         result.prog := tup.prog;
         result.name := substring(tup.name::text from 0 for 21);
         result.mark := tup.mark;
         result.grade := tup.grade;
         if tup.mark is not null then 
            weightedSumOfMarks := weightedSumOfMarks + tup.mark*tup.uoc;
         end if;
         if tup.grade in (
            'SY', 'PT', 'PC', 'PS', 'CR', 'DN', 'HD',
            'XE', 'PE', 'RC', 'RS', 'T', 'A', 'B', 'C')
         then 
            result.uoc := tup.uoc;
            UOCpassed := UOCpassed + tup.uoc;
         else
            result.uoc := null;
         end if;
         if tup.grade not in ('SY', 'XE', 'T', 'PE') then
            totalUOCattempted := totalUOCattempted + tup.uoc;
         end if;
         return next result;
      end loop;
      result.code := null;
      result.term := null;
      result.prog := null;
      result.grade := null;
      if UOCpassed > 0 then
         result.name = 'Overall WAM/UOC';
         result.mark = round(weightedSumOfMarks/totalUOCattempted);
         result.uoc = UOCpassed;
      else
         result.name = 'No WAM availiable';
         result.mark = null;
         result.uoc = null;
      end if;
      return next result;
   end;
$$ language plpgsql;

-- Q9: members of academic object group

create or replace function
   Q9(gid integer) returns setof AcObjRecord
as $$
   declare
      tup record;
      childtup AcObjRecord;
      childid integer;
      strTup text;
      result AcObjRecord;
      gtype AcadObjectGroupType;
      gdefBy AcadObjectGroupDefType;
      definition text;
      tableOfType text;
      command text;
      negated boolean;
   begin
      gdefBy := (select a.gdefBy from Acad_object_groups a where a.id = gid);
      gtype := (select a.gtype from Acad_object_groups a where a.id = gid);
      negated := (select a.negated from Acad_object_groups a where a.id = gid);
      definition := (select a.definition from Acad_object_groups a where a.id = gid);
      tableOfType := gtype || 's';

      -- handle the enumerated group
      if gdefBy = 'enumerated' and negated = false then
         command :=  'select s.code, s.id from ' || quote_ident(tableOfType) || ' s join ' 
                  || quote_ident(gtype||'_group_members') || ' m on (s.id = m.'
                  || gtype || ')'
                  || 'where m.ao_group = ' || quote_literal(gid);
         for tup in execute command loop
         result.objtype := gtype;
         result.objcode := tup.code;
         return next result;
         end loop;
      end if;

      if gdefBy = 'pattern' and (gtype = 'subject' or gtype = 'program') and negated = false then
         if 
            definition !~ 'FREE' and definition !~ 'GEN' and definition !~ 'F=' 
         then
            -- preprocess the string
            definition := regexp_replace(definition, '}', '', 'g');
            definition := regexp_replace(definition, '{', '', 'g');
            definition := regexp_replace(definition, ';', ',', 'g');
            -- handle each pattern
            for strTup in (select * from regexp_split_to_table(definition, ',')) loop
               result.objtype := gtype;
               strTup := regexp_replace(strTup, '#', '.','g');
               command := 'select * from ' || quote_ident(tableOfType) 
                        || ' s where s.code ~ ' || quote_literal(strTup);
               for tup in execute command loop
                  result.objcode := tup.code;
                  return next result;
               end loop;
            end loop;
         end if;
      end if;
      -- children
      for childid in (
         select a.id 
         from Acad_object_groups a
         where a.parent = gid
      ) loop
         for childtup in select * from Q9(childid) loop
            result.objcode := childtup.objcode;
            result.objtype := childtup.objtype;
            return next result; 
         end loop;
      end loop;
   end;
$$ language plpgsql;

-- Q10: follow-on courses

create or replace function
   Q10(code text) returns setof text
as $$
   declare 
      tup record;
      result text;
      input text := code;
   begin
      for result in (
         select distinct s.code
         from Subject_prereqs p
            join subjects s on (s.id = p.subject)
            join rules r on (r.id = p.rule)
            join Acad_object_groups a on (a.id = r.ao_group)
         where a.definition ~ input
      ) loop
         return next result;
      end loop;
   end;
$$ language plpgsql;
