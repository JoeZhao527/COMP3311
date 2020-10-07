create table Account (
    accountNo   text,
    branchName  text not null,
    balance     integer not null,
    primary key (accountNo)
);

create table Owner (
    account     text,
    customer    integer,
    primary key (account),
    foreign key (account) references Account(accountNo)
);