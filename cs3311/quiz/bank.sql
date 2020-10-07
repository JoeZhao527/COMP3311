create table Account {
    accountNo   char(5),
    branchName  text not null,
    balance     integer not null
    primary key (accountNo)
}

create table Owner {
    account     char(5),
    customer    integer,
    primary key (account),
    foreign key (account) references Account(accountNo)
}