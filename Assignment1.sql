-- bank1 table creation --
create table accounts(Account_No int primary key auto_increment, Acc_Name varchar(30) not null, Balance numeric(10,2));

-- bank_update1 table creation --
create table bank_transactions (Account_No int not null ,
Acc_Name varchar(30) not null,
changed_id timestamp,
before_Bal numeric(10,2) not null,
after_Bal numeric(10,2) not null,
Actions varchar(10) null,
Transaction_amt int null);

-- inserting the value inot bank1 table --
insert into accounts(Acc_Name, Balance ) values('Jack',30000.00);

-- trigger for after_bank_transactions_d (debit) update on accounts --
delimiter $$
create trigger after_bank_transactions_d after update on accounts for each row
begin
if(new.Balance<old.Balance) then
	insert into bank_transactions(Account_No , Acc_Name , changed_id , before_Bal , after_Bal, Actions, Transaction_amt ) 
	values(old.Account_No, old.Acc_Name, now(), old.Balance , new.Balance, 'Debit',-(old.Balance-new.Balance));
end IF;
end $$

-- trigger for after_bank_transactions_c (credit) update on bank1 --
delimiter $$
create trigger after_bank_transactions_c after update on accounts for each row
begin
if(new.Balance>old.Balance) then
	insert into bank_transactions(Account_No , Acc_Name , changed_id , before_Bal , after_Bal, Actions ,Transaction_amt) 
	values(old.Account_No, old.Acc_Name, now(), old.Balance , new.Balance, 'Credit',(new.Balance-old.Balance));
end IF;
end $$

-- update statemnt bank1 table --
update accounts set Balance = (Balance-1000) where Account_No = 3;
update accounts set Balance = (Balance+1000) where Account_No = 2;

-- dropping the both the triggers --
drop trigger after_bank_transactions_d;
drop trigger after_bank_transactions_c;


-- CREATE PROCEDURE HOURLY_SUM -- 
DELIMITER //
CREATE PROCEDURE HOURLY_SUM (IN Account_No INT, OUT WTotal numeric(10,2), OUT DTotal numeric(10,2))
BEGIN
    SELECT sum(Transaction_amt) INTO WTotal FROM bank_transactions
	WHERE Actions = 'Debit' AND Account_No=Account_No AND changed_id >= Date_sub(now(),interval 1 hour);
    
    SELECT sum(Transaction_amt) INTO DTotal FROM bank_transactions
	WHERE Actions = 'Credit' AND Account_No=Account_No AND changed_id >= Date_sub(now(),interval 1 hour);
END //

-- DROP THE PROCEDURE --
DROP PROCEDURE HOURLY_SUM;

-- CALLING THE PROCEDURE --
CALL HOURLY_SUM(1, @WTotal, @DTotal);

-- DISPLAYING THE CALLED PROCEDURE --
SELECT @WTotal, @DTotal;

-- CREATING EVENT TO CALL PROCEDURE HOURLY--
CREATE EVENT MyEvent
    ON SCHEDULE EVERY 1 HOUR
    DO
      CALL HOURLY_SUM(1, @WTotal, @DTotal);

-- DROP THR EVENT --
DROP EVENT MyEvent;