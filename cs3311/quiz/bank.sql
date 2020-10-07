create table Account (
    branchName  text not null,
    accountNo   text,
    balance     integer not null,
    primary key (accountNo)
);

create table Owner (
    account     text,
    customer    integer,
    primary key (account,customer),
    foreign key (account) references Account(accountNo)
);