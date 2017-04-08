USE master;
GO

/*
1. Необходимо разработать базу данных «Книжный магазин» 
предусмотреть возможность выполнения следующих типов запросов:
Выбрать самые популярные 10  книг.
Показать статистику времени покупки книг, в какое время больше всего, 
в какое меньше покупают книги.
Какие авторы пользуются наибольшей популярностью у покупателей
Максимальная и минимальная стоимость книги.
Список продавцов, которые продали максимальное количество книг за указанный период.
Сумму премий каждого продавца. Предположим, 
что премия рассчитывается по следующему алгоритму: 
1000-1299 грн премия 10% от закупочной стоимости книг
1300-1499 грн премия 15% от закупочной стоимости книг
1500-1999 грн премия 25% от закупочной стоимости книг
2000-3000 грн премия 40% от закупочной стоимости книг
2. Все выше перечисленные запросы реализовать в виде хранимых процедур.  
*/

CREATE DATABASE BookStore
ON PRIMARY
(
	NAME = BookStoreDate,
	FILENAME = 'C:\sql_db\BookStore\BookStore.mdf',
	SIZE = 10,
	MAXSIZE = 300,
	FILEGROWTH = 5
)
LOG ON
(
	NAME = BookStoreLog,
	FILENAME = 'C:\sql_db\BookStore\BookStore.ldf',
	SIZE = 10,
	MAXSIZE = 150,
	FILEGROWTH = 5
);
GO

USE BookStore;
GO

CREATE TABLE BookStore.dbo.Themes
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Name nvarchar(50) NOT NULL,

	CONSTRAINT UniqName UNIQUE (Name)
);
GO

CREATE TABLE BookStore.dbo.Category
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Name nvarchar(50) NOT NULL,

	CONSTRAINT UniqNameCategory UNIQUE (Name) 
);
GO

CREATE TABLE BookStore.dbo.Authors
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,

	CONSTRAINT UniqAuthor UNIQUE (FirstName, LastName)
);
GO

CREATE TABLE BookStore.dbo.Press
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Name nvarchar(50) NOT NULL
);
GO

CREATE TABLE BookStore.dbo.Books
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Name nvarchar(100) NOT NULL,
	Price smallmoney NOT NULL DEFAULT (0.0),
	Сoming smalldatetime NOT NULL DEFAULT (GETDATE()),
	Pages int NOT NULL,
	YearPress int NOT NULL,
	Id_Themes int NOT NULL,
	Id_Category int NOT NULL,
	Id_Author int NOT NULL,
	Id_Press int NOT NULL,
	Comment nvarchar(100),
	Quantity int NOT NULL,

	CONSTRAINT Books_T FOREIGN KEY (Id_Themes)
	REFERENCES Themes (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT Books_C FOREIGN KEY (Id_Category)
	REFERENCES Category (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT Books_A FOREIGN KEY (Id_Author)
	REFERENCES Authors (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT Books_P FOREIGN KEY (Id_Press)
	REFERENCES Press (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
GO

CREATE TABLE BookStore.dbo.Sellers
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,

	CONSTRAINT UniqSeller UNIQUE (FirstName, LastName)
);
GO

CREATE TABLE BookStore.dbo.Buyers
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,

	CONSTRAINT UniqBuyer UNIQUE (FirstName, LastName)
);
GO

CREATE TABLE BookStore.dbo.Selling
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Id_Buyer int NOT NULL,
	Id_Seller int NOT NULL,
	Id_Book int NOT NULL,
	Quantity int NOT NULL,
	TimeOfPurchase smalldatetime NOT NULL DEFAULT(GETDATE()),
	
	CONSTRAINT Buyer FOREIGN KEY (Id_Buyer)
	REFERENCES Buyers (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,  

	CONSTRAINT Seller FOREIGN KEY (Id_Seller)
	REFERENCES Sellers (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT Book_S FOREIGN KEY (Id_Book)
	REFERENCES Books (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
 );
 GO

CREATE TABLE BookStore.dbo.Salary
(
	Id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Id_Seller int NOT NULL,
	Bonus smallmoney,
	Wage  smallmoney,
	SalaryTime smalldatetime NOT  NULL CHECK (DATEPART (dd, SalaryTime) = 25),  

	CONSTRAINT Wage FOREIGN KEY (Id_Seller)
	REFERENCES Sellers (Id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
);
GO

CREATE TRIGGER WhenBuying
ON Selling
FOR INSERT
AS
	DECLARE @Id_book int, @quantity int;
	SELECT @Id_book = Id_Book, @quantity = Quantity
	FROM inserted;

	UPDATE Books
	SET Quantity = Quantity - @quantity
	WHERE Id = @Id_book;
GO

 INSERT INTO 
	BookStore.dbo.Themes
	(
		Name
	)
 SELECT	
	Name
 FROM library.dbo.Themes;
 GO

  INSERT INTO 
	BookStore.dbo.Category
	(
		Name
	)
 SELECT	
	Name
 FROM library.dbo.Categories;
 GO

  INSERT INTO 
	BookStore.dbo.Authors
	(
		FirstName,
		LastName
	)
 SELECT	
	FirstName,
	LastName
 FROM library.dbo.Authors;
 GO

  INSERT INTO 
	BookStore.dbo.Press
	(
		Name
	)
 SELECT	
	Name
 FROM library.dbo.Press;
 GO

 INSERT INTO 
	BookStore.dbo.Books
	(
		Name,
		Pages,
		YearPress,
		Id_Themes,
		Id_Category,
		Id_Author,
		Id_Press, 
		Comment,
		Quantity
	)
 SELECT	
	Name,
	Pages,
	YearPress,
	Id_Themes,
	Id_Category,
	Id_Author,
	Id_Press, 
	Comment,
	Quantity
 FROM library.dbo.Books;
 GO

 -- Sellers
INSERT INTO BookStore.dbo.Sellers
VALUES (N'Alexander', N'Freeman');

INSERT INTO BookStore.dbo.Sellers
VALUES (N'Aiden', N'Tilman');

INSERT INTO BookStore.dbo.Sellers
VALUES (N'Emma', N'Fanson');
GO

-- Buyers
INSERT INTO BookStore.dbo.Buyers
VALUES (N'Marilyn', N'Manson');

INSERT INTO BookStore.dbo.Buyers
VALUES (N'Till', N'Lindemann');

INSERT INTO BookStore.dbo.Buyers
VALUES (N'Max', N'Cavalera');
GO

-- Make a purchase
INSERT INTO BookStore.dbo.Selling(Id_Buyer, Id_Seller, Id_Book, Quantity, TimeOfPurchase)
VALUES (2, 3, 8, 2, '2017-04-05 16:48:00');
INSERT INTO BookStore.dbo.Selling(Id_Buyer, Id_Seller, Id_Book, Quantity)
VALUES (1, 1, 1, 1);
INSERT INTO BookStore.dbo.Selling(Id_Buyer, Id_Seller, Id_Book, Quantity)
VALUES (2, 3, 14, 2);
INSERT INTO BookStore.dbo.Selling(Id_Buyer, Id_Seller, Id_Book, Quantity)
VALUES (3, 2, 10, 3);
GO

-- Выбрать самые популярные 10  книг.
CREATE PROCEDURE TOP10
AS
SELECT DISTINCT TOP (10) Books.Name AS Book, Books.Price, SUM (Selling.Quantity) AS Quantity
FROM Selling, Books
WHERE Selling.Id_Book = Books.Id
GROUP BY Books.Name, Books.Price
ORDER BY SUM (Selling.Quantity) DESC;
GO

EXECUTE TOP10;
GO

EXECUTE sp_helptext TOP10;
GO

EXECUTE sp_help TOP10;
GO

-- Показать статистику времени покупки книг,
-- в какое время больше всего, в какое меньше покупают книги.
CREATE PROCEDURE SellTimeStatistic
AS
DECLARE @Day int
SELECT @Day = SUM (Selling.Quantity)		
FROM Selling
WHERE DATEPART (hh ,TimeOfPurchase) <= 15

DECLARE @Evening int
SELECT @Evening = SUM (Selling.Quantity) 	
FROM Selling
WHERE DATEPART (hh ,TimeOfPurchase) > 15 

SELECT @Day AS [Day], @Evening AS Evening; 
GO

EXECUTE SellTimeStatistic;
GO

-- Какие авторы пользуются наибольшей популярностью у покупателей
CREATE PROCEDURE PopularAuthors
AS
SELECT DISTINCT TOP (10)  Authors.FirstName + ' ' + Authors.LastName AS Author,
						 SUM (Selling.Quantity) AS Quantity
FROM Selling, Books, Authors
WHERE Selling.Id_Book = Books.Id AND Books.Id_Author = Authors.Id
GROUP BY  Authors.FirstName + ' ' + Authors.LastName
ORDER BY SUM (Selling.Quantity) DESC;
GO

EXECUTE PopularAuthors;
GO

-- Максимальная и минимальная стоимость книги.
CREATE PROCEDURE MinMaxPrice
AS
SELECT MIN (Books.Price) AS [Min Price] , MAX (Books.Price) AS [Max Price]
FROM Books;
GO

EXECUTE MinMaxPrice;
GO

-- Список продавцов, которые продали максимальное количество книг за указанный период.
CREATE PROCEDURE ListSellersMaxSell
AS
SELECT DISTINCT TOP (5)  Sellers.FirstName + ' ' + Sellers.LastName AS Seller,
						 SUM (Selling.Quantity) AS Quantity
FROM Selling, Books, Sellers
WHERE Selling.Id_Book = Books.Id AND Selling.Id_Seller =Sellers.Id
GROUP BY  Sellers.FirstName + ' ' + Sellers.LastName
ORDER BY SUM (Selling.Quantity) DESC;
GO

EXECUTE ListSellersMaxSell;
GO

-- Сумму премий каждого продавца. Предположим, 
--		что премия рассчитывается по следующему алгоритму: 
-- 1000-1299 грн премия 10% от закупочной стоимости книг
-- 1300-1499 грн премия 15% от закупочной стоимости книг
-- 1500-1999 грн премия 25% от закупочной стоимости книг
-- 2000-3000 грн премия 40% от закупочной стоимости книг
CREATE PROCEDURE Accrual
AS
IF (DATEPART (dd, GETDATE ()) <> 25)
BEGIN
	PRINT (N'Not time for salary and bonus!');
	RETURN;
END

DECLARE @QuantitySellers int;
SELECT @QuantitySellers = COUNT(Sellers.Id)
FROM Sellers;

WHILE (@QuantitySellers > 0)
BEGIN
	INSERT INTO BookStore.dbo.Salary(Id_Seller, Wage, SalaryTime)
	VALUES (@QuantitySellers, 3500, GETDATE());

	SET @QuantitySellers -= 1;
END

DECLARE @TempSalesAmount TABLE (id int, amount smallmoney, bonus smallmoney);
INSERT  @TempSalesAmount
SELECT Sellers.Id, SUM (Books.Price) AS [Sales amount], Bonus
FROM Selling, Books, Sellers, Salary
WHERE Selling.Id_Book = Books.Id 
	AND 
	Selling.Id_Seller = Sellers.Id 
	AND  
	Salary.Id_Seller = Sellers.Id
GROUP BY Sellers.Id, Bonus;

Update @TempSalesAmount
SET Bonus = amount * 0.1
WHERE amount BETWEEN 1000 AND 1299;

Update @TempSalesAmount
SET Bonus = amount * 0.15
WHERE amount BETWEEN 1300 AND 1499;

Update @TempSalesAmount
SET Bonus = amount * 0.25
WHERE amount BETWEEN 1500 AND 1999;

Update @TempSalesAmount
SET Bonus = amount * 0.4
WHERE amount BETWEEN 2000 AND 3000;

DECLARE @Index int, @TempBonus smallmoney;

SELECT @Index = COUNT(Sellers.Id)
FROM Sellers;

WHILE (@Index > 0)
BEGIN 
	SELECT @TempBonus = temp.bonus
	FROM @TempSalesAmount temp
	WHERE temp.id = @Index;

	UPDATE Salary
	SET Bonus = @TempBonus
	WHERE Salary.Id_Seller = @Index;
	
	SET @Index -= 1;
END
GO		

EXECUTE Accrual;
GO

CREATE PROCEDURE SumBonus
AS
SELECT Sellers.FirstName + ' ' + Sellers.LastName AS Seller, SUM (Salary.Bonus)
FROM Sellers, Salary
WHERE Sellers.Id = Salary.Id_Seller
GROUP BY Sellers.FirstName + ' ' + Sellers.LastName;
GO

EXECUTE SumBonus;
GO

-- 4. Реализовать хранимые процедуры для выполнения операций добавления,
-- удаления и обновления данных хранящихся в таблицах базы данных.

CREATE PROCEDURE add_book
@name nvarchar(100),
@price smallmoney,
@pages int,
@yearPress int,
@id_Themes int,
@id_Category int,
@id_Author int,
@id_Press int,
@quantity int,
@comment nvarchar(100) = NULL
AS
INSERT INTO BookStore.dbo.Books
(
	Name, Price, Pages, YearPress, Id_Themes, Id_Category,
	Id_Author, Id_Press, Quantity, Comment
)
VALUES
(
	@name, @price, @pages, @yearPress, @id_Themes, @id_Category,
	@id_Author, @id_Press, @quantity, @comment
);
GO

EXECUTE add_book N'first', 111.1, 100, 2000, 1, 1, 1, 1, 1, N'fgr' ;
GO

CREATE PROCEDURE alter_book
@id int,
@name nvarchar(100),
@price smallmoney,
@coming smalldatetime,
@pages int,
@yearPress int,
@id_Themes int,
@id_Category int,
@id_Author int,
@id_Press int,
@quantity int,
@comment nvarchar(100) = NULL
AS
UPDATE Books
SET Name = @name,
	Price = @price,
	Books.Сoming = @coming,
	Pages = @pages,
	YearPress = @yearPress,
	Id_Themes = @id_Themes,
	Id_Category = @id_Category,
	Id_Author = @id_Author,
	Id_Press = @id_Press,
	Quantity = @quantity,
	Comment = @comment
WHERE Id = @id;
GO

EXECUTE alter_book 56, N'C#', 444.1, '2017-04-05 16:26:00', 100, 2000, 1, 1, 1, 1, 1;
GO

CREATE PROCEDURE remove_book
@id int
AS
DELETE 
FROM Books
WHERE Id = @id;
GO

EXECUTE remove_book 55;
GO

CREATE PROCEDURE add_author
@first_name nvarchar(100),
@last_name nvarchar(100)
AS
INSERT INTO BookStore.dbo.Authors
(
	FirstName, LastName
)
VALUES
(
	@first_name, @last_name
);
GO

EXECUTE add_author 'Herbert', 'Schildt';
GO

CREATE PROCEDURE alter_author
@id int,
@first_name nvarchar(100),
@last_name nvarchar(100)
AS
UPDATE Authors
SET FirstName = @first_name,
	LastName = @last_name
WHERE Id = @id;
GO

EXECUTE alter_author 43, 'rr', 'ff';
GO

CREATE PROCEDURE remove_author
@id int
AS
DELETE 
FROM Authors
WHERE Id = @id;
GO

EXECUTE remove_author 43;
GO		

CREATE PROCEDURE add_buyer
@first_name nvarchar(100),
@last_name nvarchar(100)
AS
INSERT INTO BookStore.dbo.Buyers
(
	FirstName, LastName
)
VALUES
(
	@first_name, @last_name
);
GO

EXECUTE add_buyer 'Her', 'Schi';
GO

CREATE PROCEDURE alter_buyer
@id int,
@first_name nvarchar(100),
@last_name nvarchar(100)
AS
UPDATE Buyers
SET FirstName = @first_name,
	LastName = @last_name
WHERE Id = @id;
GO

EXECUTE alter_buyer 10, 'Richie', 'Fear';
GO

CREATE PROCEDURE remove_buyer
@id int
AS
DELETE 
FROM Buyers
WHERE Id = @id;
GO

EXECUTE remove_buyer 10;
GO	

CREATE PROCEDURE add_category
@name nvarchar(50)
AS
INSERT INTO BookStore.dbo.Category
(
	Name
)
VALUES
(
	@name
);
GO

EXECUTE add_category 'Server';
GO

CREATE PROCEDURE alter_category
@id int,
@name nvarchar(50)
AS
UPDATE Category
SET Name = @name
WHERE Id = @id;
GO

EXECUTE alter_category 43, 'Hardware';
GO

CREATE PROCEDURE remove_category
@id int
AS
DELETE 
FROM Category
WHERE Id = @id;
GO

EXECUTE remove_category 43;
GO	

CREATE PROCEDURE add_press
@name nvarchar(50)
AS
INSERT INTO BookStore.dbo.Press
(
	Name
)
VALUES
(
	@name
);
GO

EXECUTE add_press 'PPP';
GO

CREATE PROCEDURE alter_press
@id int,
@name nvarchar(50)
AS
UPDATE Press
SET Name = @name
WHERE Id = @id;
GO

EXECUTE alter_press 22, 'Hard';
GO

CREATE PROCEDURE remove_press
@id int
AS
DELETE 
FROM Press
WHERE Id = @id;
GO

EXECUTE remove_press 22;
GO	

CREATE PROCEDURE add_seller
@first_name nvarchar(100),
@last_name nvarchar(100)
AS
INSERT INTO BookStore.dbo.Sellers
(
	FirstName, LastName
)
VALUES
(
	@first_name, @last_name
);
GO

EXECUTE add_seller 'Alberto', 'Sendler';
GO

CREATE PROCEDURE alter_seller
@id int,
@first_name nvarchar(100),
@last_name nvarchar(100)
AS
UPDATE Sellers
SET FirstName = @first_name,
	LastName = @last_name
WHERE Id = @id;
GO

EXECUTE alter_seller 10, 'rr', 'ff';
GO

CREATE PROCEDURE remove_seller
@id int
AS
DELETE 
FROM Sellers
WHERE Id = @id;
GO

EXECUTE remove_seller 10;
GO		

CREATE PROCEDURE add_theme
@name nvarchar(50)
AS
INSERT INTO BookStore.dbo.Themes
(
	Name
)
VALUES
(
	@name
);
GO

EXECUTE add_theme 'PPP';
GO

CREATE PROCEDURE alter_theme
@id int,
@name nvarchar(50)
AS
UPDATE Themes
SET Name = @name
WHERE Id = @id;
GO

EXECUTE alter_theme 28, 'Hard';
GO

CREATE PROCEDURE remove_theme
@id int
AS
DELETE 
FROM Themes
WHERE Id = @id;
GO

EXECUTE remove_theme 28;
GO	

CREATE PROCEDURE make_purchase
@id_buyer int,
@id_seller int,
@id_book int,
@quantity int
AS
INSERT INTO BookStore.dbo.Selling(Id_Buyer, Id_Seller, Id_Book, Quantity)
VALUES (@id_buyer, @id_seller, @id_book, @quantity);
GO

EXECUTE make_purchase 1, 2, 3, 4;
GO

-- 5. Реализовать триггеры выполняющие следующие задачи:
--  Возможность добавления новый книги только в том случае
-- если остаток на складе не превышает 25 штук.
CREATE TRIGGER insert_new_book
ON Books
FOR INSERT
AS
DECLARE @quantity_books int;
SELECT @quantity_books = SUM(Quantity)
FROM Books;

IF (@quantity_books > 25)
BEGIN
	PRINT(N'The quantity in the store exceeds 25 pcs.');
	ROLLBACK TRANSACTION;
END
GO

--  Удалить (списать) книги только тогда,
-- когда срок хранение на скале превысил 1 год.
CREATE TRIGGER delete_old_book
ON Books
FOR DELETE
AS
DECLARE @less_date smalldatetime,
		@day_in_year int;

SELECT @less_date = MIN (deleted.Сoming) 
FROM deleted;

SET @day_in_year = YEAR (@less_date);

IF ((@day_in_year % 4 = 0 AND @day_in_year % 100 <> 0) OR @day_in_year % 400 = 0)
BEGIN
	-- (366 - 1) because DATEDIFF counts from the date
	SET	@day_in_year = 365;
END
ELSE
BEGIN
	-- (365 - 1) because DATEDIFF counts from the date
	SET	@day_in_year = 364;
END

IF (DATEDIFF (DD, @less_date, GETDATE ()) < @day_in_year)
BEGIN
	PRINT('You can not delete books that came less than a year ago!');
	ROLLBACK TRANSACTION;
END
GO

-- 6. Реализовать пользовательскую функцию, 
-- которая считает скидку покупателя(по его ID). Предположим: 
-- покупка на сумму 100-299 гривен скидка составляет 2% 
-- 300-499 гривен скидка 5%
-- 500-999 гривен скидка 7%
-- 1000 и более скидка 10% 
CREATE FUNCTION Discount
(
	@id_buyer int
)
RETURNS smallmoney
AS
BEGIN
	DECLARE @sum smallmoney;
	SELECT @sum = SUM (Books.Price)
	FROM Buyers, Selling, Books
	WHERE Selling.Id_Buyer = Buyers.Id 
		AND 
		Selling.Id_Book = Books.Id 
		AND 
		Buyers.Id = @id_buyer;

	DECLARE @rebate smallmoney;
	SET @rebate =
		(CASE 
			WHEN (@sum  BETWEEN 100 AND 299)  THEN  @sum * 0.02
			WHEN (@sum  BETWEEN 300 AND 499)  THEN  @sum * 0.05
			WHEN (@sum  BETWEEN 500 AND 999)  THEN  @sum * 0.07
			WHEN (@sum  > 1000)  THEN  @sum * 0.1
		END
		)
	RETURN @rebate;
END
GO

SELECT dbo.Discount(1);
GO

-- 7. С помощью индексов выполнить индексирование необходимых
-- полей в таблице «Книги». Вам необходимо самостоятельно принять
-- решение по каким полям делать индексы.

/*
-- Watch Bonus
SELECT Sellers.Id, SUM (Books.Price) AS [Sales amount], Bonus
FROM Selling, Books, Sellers, Salary
WHERE Selling.Id_Book = Books.Id 
	AND 
	Selling.Id_Seller = Sellers.Id 
	AND  
	Salary.Id_Seller = Sellers.Id
GROUP BY Sellers.Id, Bonus;
GO
*/

/*
-- Watch Selling
SELECT Selling.Id, 
	   Buyers.FirstName + ' ' + Buyers.LastName AS Buyer,
	   Sellers.FirstName + ' ' + Sellers.LastName AS Seller,
	   Books.Name AS Book, Books.Price,
	   Authors.FirstName + ' ' + Authors.LastName AS Author,
	   Selling.Quantity, Selling.TimeOfPurchase
FROM Books, Selling, Sellers, Buyers, Authors
WHERE Selling.Id_Book = Books.Id 
	  AND 
	  Selling.Id_Buyer = Buyers.Id 
	  AND 
	  Selling.Id_Seller = Sellers.Id
	  AND
	  Books.Id_Author = Authors.Id;
GO
*/

/*
-- Watch books in store
SELECT Books.Id, Books.Name, Books.Price, Books.Сoming, Books.YearPress,
	   Books.Comment, Authors.FirstName + ' ' + Authors.LastName AS Author,
	   Category.Name AS Category, Press.Name AS Press, Themes.Name AS Themes, Quantity 
FROM Books, Themes, Category, Authors, Press
WHERE Books.Id_Author = Authors.Id AND Books.Id_Category = Category.Id
		 AND Books.Id_Press = Press.Id AND Books.Id_Themes = Themes.Id;
GO
*/

/*
UPDATE Books
SET Quantity = 35;
GO
*/

/*
UPDATE Books
SET Price = 217.99
WHERE Id > 15 AND Id < 19;
GO
*/

/*
USE master;
GO

DROP DATABASE BookStore;
GO
*/
