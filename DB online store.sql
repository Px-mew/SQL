#Предметная область
#В интернет-магазине продаются книги. Каждая книга имеет название, написана одним автором, относится к одному жанру, имеет определенную цену. В магазине в наличии есть несколько экземпляров каждой книги.

#Покупатель регистрируется на сайте интернет-магазина, задает свое имя и фамилию, электронную почту и город проживания.
#Он может сформировать один или несколько заказов, для каждого заказа написать какие-то пожелания. Каждый заказ включает одну или несколько книг, каждую книгу можно заказать в нескольких экземплярах.
#Затем заказ проходит ряд последовательных этапов (операций): оплачивается, упаковывается, передается курьеру или транспортной компании для транспортировки и, наконец, доставляется #покупателю.
#Фиксируется дата каждой операции. Для каждого города известно среднее время доставки книг.

#При этом в магазине ведется учет книг, при покупке их количество уменьшается, при поступлении товара увеличивается, при исчерпании количества – оформляется заказ и пр.
CREATE DATABASE online_store;

CREATE TABLE author (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
);

INSERT INTO author (name_author)
VALUES ('Булгаков М.А.'),
       ('Достоевский Ф.М.'),
       ('Есенин С.А.'),
       ('Пастернак Б.Л.'),
       ('Лермонтов М.Ю.');

CREATE TABLE genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name_genre VARCHAR(30)
);

INSERT INTO genre(name_genre)
VALUES ('Роман'),
       ('Поэзия'),
       ('Приключения');

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author_id INT NOT NULL,
    genre_id INT,
    price DECIMAL(8, 2),
    amount INT,
    FOREIGN KEY (author_id)
        REFERENCES author (author_id)
        ON DELETE CASCADE,
    FOREIGN KEY (genre_id)
        REFERENCES genre (genre_id)
        ON DELETE SET NULL
);

INSERT INTO book (title, author_id, genre_id, price, amount)
VALUES  ('Мастер и Маргарита', 1, 1, 670.99, 3),
        ('Белая гвардия ', 1, 1, 540.50, 5),
        ('Идиот', 2, 1, 460.00, 10),
        ('Братья Карамазовы', 2, 1, 799.01, 2),
        ('Игрок', 2, 1, 480.50, 10),
        ('Стихотворения и поэмы', 3, 2, 650.00, 15),
        ('Черный человек', 3, 2, 570.20, 6),
        ('Лирика', 4, 2, 518.99, 2);

#Таблица city (в последнем столбце указано примерное количество дней, необходимое для доставки товара в каждый город):
CREATE TABLE city (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    name_city VARCHAR(30),
    days_delivery INT
);

INSERT INTO city(name_city, days_delivery)
VALUES ('Москва', 5),
       ('Санкт-Петербург', 3),
       ('Владивосток', 12);

CREATE TABLE client (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    name_client VARCHAR(50),
    city_id INT,
    email VARCHAR(30),
    FOREIGN KEY (city_id) REFERENCES city (city_id)
);

INSERT INTO client(name_client, city_id, email)
VALUES ('Баранов Павел', 3, 'baranov@test'),
       ('Абрамова Катя', 1, 'abramova@test'),
       ('Семенонов Иван', 2, 'semenov@test'),
       ('Яковлева Галина', 1, 'yakovleva@test');

#Таблица buy (столбец buy_description предназначен для пожеланий покупателя,
#которые он хочет добавить в свой заказ, если пожеланий нет - поле остается пустым):
CREATE TABLE buy(
    buy_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_description VARCHAR(100),
    client_id INT,
    FOREIGN KEY (client_id) REFERENCES client (client_id)
);

INSERT INTO buy (buy_description, client_id)
VALUES ('Доставка только вечером', 1),
       (NULL, 3),
       ('Упаковать каждую книгу по отдельности', 2),
       (NULL, 1);

CREATE TABLE buy_book (
    buy_book_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    book_id INT,
    amount INT,
    FOREIGN KEY (buy_id) REFERENCES buy (buy_id),
    FOREIGN KEY (book_id) REFERENCES book (book_id)
);

INSERT INTO buy_book(buy_id, book_id, amount)
VALUES (1, 1, 1),
       (1, 7, 2),
       (1, 3, 1),
       (2, 8, 2),
       (3, 3, 2),
       (3, 2, 1),
       (3, 1, 1),
       (4, 5, 1);

CREATE TABLE step (
    step_id INT PRIMARY KEY AUTO_INCREMENT,
    name_step VARCHAR(30)
);

INSERT INTO step(name_step)
VALUES ('Оплата'),
       ('Упаковка'),
       ('Транспортировка'),
       ('Доставка');

#Таблица buy_step ( если столбец date_step_end не заполнен (имеет значение Null),
#это означает что операция еще не выполнена, например для заказа с id 2, книги переданы для доставки 2020-03-02, но еще не доставлены):
CREATE TABLE buy_step (
    buy_step_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    step_id INT,
    date_step_beg DATE,
    date_step_end DATE,
    FOREIGN KEY (buy_id) REFERENCES buy (buy_id),
    FOREIGN KEY (step_id) REFERENCES step (step_id)
);

INSERT INTO buy_step(buy_id, step_id, date_step_beg, date_step_end)
VALUES (1, 1, '2020-02-20', '2020-02-20'),
       (1, 2, '2020-02-20', '2020-02-21'),
       (1, 3, '2020-02-22', '2020-03-07'),
       (1, 4, '2020-03-08', '2020-03-08'),
       (2, 1, '2020-02-28', '2020-02-28'),
       (2, 2, '2020-02-29', '2020-03-01'),
       (2, 3, '2020-03-02', NULL),
       (2, 4, NULL, NULL),
       (3, 1, '2020-03-05', '2020-03-05'),
       (3, 2, '2020-03-05', '2020-03-06'),
       (3, 3, '2020-03-06', '2020-03-10'),
       (3, 4, '2020-03-11', NULL),
       (4, 1, '2020-03-20', NULL),
       (4, 2, NULL, NULL),
       (4, 3, NULL, NULL),
       (4, 4, NULL, NULL);

#Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал)
#в отсортированном по номеру заказа и названиям книг виде.
SELECT buy_id, title, price, buy_book.amount
FROM client
  INNER JOIN buy USING(client_id)
  INNER JOIN buy_book USING(buy_id)
  INNER JOIN book USING(book_id)
WHERE name_client = 'Баранов Павел'
ORDER BY buy_id, title;

#Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).
#Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.
SELECT name_author, title,  COUNT(buy_book.amount) AS Количество
FROM author
  RIGHT JOIN book USING(author_id)
  LEFT JOIN buy_book USING(book_id)
GROUP BY name_author, title
ORDER BY name_author, title;

#Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый город, этот столбец назвать Количество.
#Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.
SELECT name_city, COUNT(buy_id) AS Количество
FROM city
  INNER JOIN client USING(city_id)
  LEFT JOIN buy USING(client_id)
GROUP BY name_city
ORDER BY Количество DESC, name_city;

#Вывести номера всех оплаченных заказов и даты, когда они были оплачены.
SELECT buy_id, date_step_end
FROM step INNER JOIN buy_step USING (step_id)
WHERE name_step = 'Оплата' AND date_step_end IS NOT NULL;

#Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений количества заказанных книг и их цены),
#в отсортированном по номеру заказа виде.
#Последний столбец назвать Стоимость.
SELECT buy_id, name_client, SUM(buy_book.amount* price) AS Стоимость
FROM client
     RIGHT JOIN buy USING (client_id)
     LEFT JOIN buy_book USING (buy_id)
     INNER JOIN book USING (book_id)
GROUP BY buy_id, name_client
ORDER BY buy_id;

#Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. Если заказ доставлен –  информацию о нем не выводить.
#Информацию отсортировать по возрастанию buy_id.
SELECT buy_id, name_step
FROM step INNER JOIN buy_step USING (step_id)
WHERE date_step_beg IS NOT NULL
AND date_step_end IS NULL;

#В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап Транспортировка).
#Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город.
#А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0.
#В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде.
SELECT buy_id, DATEDIFF(date_step_end,date_step_beg) AS Количество_дней, IF(DATEDIFF(date_step_end,date_step_beg)-days_delivery > 0, DATEDIFF(date_step_end,date_step_beg)-days_delivery, 0) AS Опоздание
FROM city
    INNER JOIN client USING(city_id)
    INNER JOIN buy USING(client_id)
    INNER JOIN buy_step USING(buy_id)
    INNER JOIN step USING(step_id)
WHERE name_step = 'Транспортировка' AND date_step_beg IS NOT NULL AND date_step_end IS NOT NULL
ORDER BY buy_id;

#Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. В решении используйте фамилию автора, а не его id.
SELECT name_client
FROM author
    INNER JOIN book USING(author_id)
    INNER JOIN buy_book USING(book_id)
    INNER JOIN buy USING(buy_id)
    INNER JOIN client USING(client_id)
WHERE name_author = 'Достоевский Ф.М.'
GROUP BY name_client
ORDER BY name_client;

#Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество. Последний столбец назвать Количество.
SELECT name_genre, SUM(buy_book.amount) AS Количество
FROM genre
    INNER JOIN book USING(genre_id)
    INNER JOIN buy_book USING(book_id)
GROUP BY name_genre
LIMIT 1;

#Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы.
#Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде.
#Название столбцов: Год, Месяц, Сумма.
SELECT YEAR(date_step_end) AS Год, MONTHNAME(date_step_end) AS Месяц, SUM(price*buy_book.amount) AS Сумма
FROM book
    INNER JOIN buy_book USING(book_id)
    INNER JOIN buy USING(buy_id)
    INNER JOIN buy_step USING(buy_id)
    INNER JOIN step USING(step_id)
WHERE name_step = 'Оплата' AND date_step_end IS NOT NULL
GROUP BY Год, Месяц
UNION ALL
SELECT YEAR(date_payment) AS Год, MONTHNAME(date_payment) AS Месяц, SUM(price*amount) AS Сумма
FROM buy_archive
GROUP BY Год, Месяц
ORDER BY Месяц, Год;

#Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за текущий и предыдущий год .
#Вычисляемые столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию стоимости.
SELECT title, SUM(Количество) AS Количество, SUM(Сумма) AS Сумма
FROM (SELECT book.title, SUM(buy_book.amount) AS Количество, SUM(book.price*buy_book.amount) AS Сумма
     FROM buy_book
         INNER JOIN book USING (book_id)
         INNER JOIN buy USING(buy_id)
         INNER JOIN buy_step USING(buy_id)
         INNER JOIN step USING(step_id)
     WHERE name_step ='Оплата' AND date_step_end IS NOT NULL
GROUP BY book.title
UNION ALL
SELECT book.title, SUM(buy_archive.amount) AS Количество, SUM(buy_archive.price*buy_archive.amount) AS Сумма
        FROM buy_archive
            INNER JOIN book USING (book_id)
GROUP BY book.title) AS qwert
GROUP BY title
ORDER BY Сумма DESC;

#Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.
INSERT INTO client(name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city
WHERE name_city = 'Москва';

#Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».
INSERT INTO buy(buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки', client_id
FROM client
WHERE name_client = 'Попов Илья';

#В таблицу buy_book добавить заказ с номером 5.
#Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.
INSERT INTO buy_book(buy_id, book_id, amount)
SELECT 5, book_id, 2
FROM book INNER JOIN author USING (author_id)
WHERE name_author LIKE 'Пастернак%' AND title = 'Лирика';

INSERT INTO buy_book(buy_id, book_id, amount)
SELECT 5, book_id, 1
FROM book INNER JOIN author USING (author_id)
WHERE name_author LIKE 'Булгаков%' AND title = 'Белая гвардия';

#Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество, которое в заказе с номером 5  указано.
UPDATE book INNER JOIN buy_book USING (book_id)
SET book.amount = book.amount - buy_book. amount
WHERE buy_id = 5;

#Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг и  стоимость.
#Последний столбец назвать Стоимость. Информацию в таблицу занести в отсортированном по названиям книг виде.
CREATE TABLE buy_pay(
  title VARCHAR(50),
  name_author VARCHAR(30),
  price DECIMAL(8,2),
  amount INT,
  Стоимость DECIMAL(8,2)
);

INSERT INTO buy_pay(title, name_author, price, amount, Стоимость )
SELECT title, name_author, price, buy_book.amount, price*buy_book.amount
FROM author
  INNER JOIN book USING (author_id)
  INNER JOIN buy_book USING (book_id)
WHERE buy_book.buy_id=5
ORDER BY title ;

#Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5.
#Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого).
#Для решения используйте ОДИН запрос.
CREATE TABLE buy_pay
SELECT buy_book.buy_id, SUM(buy_book.amount) as Количество,SUM(book.price*buy_book.amount)  as Итого
FROM buy_book
  JOIN book USING(book_id)
WHERE buy_id=5
GROUP BY 1;

#В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ.
#В столбцы date_step_beg и date_step_end всех записей занести Null.
INSERT INTO buy_step(buy_id, step_id)
SELECT 5, step.step_id
FROM step

#В таблицу buy_step занести текущую дату выставления счета на оплату заказа с номером 5.
UPDATE buy_step INNER JOIN step USING (step_id)
SET date_step_beg = NOW()
WHERE name_step = 'Оплата' AND buy_id = 5;

#Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020,
#и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату.
#Реализовать два запроса для завершения этапа и начала следующего.
#Они должны быть записаны в общем виде, чтобы его можно было применять для любых этапов, изменив только текущий этап.
#Для примера пусть это будет этап «Оплата».
UPDATE buy_step INNER JOIN step USING (step_id)
SET date_step_end = '2020-04-13'
WHERE name_step = 'Оплата' AND buy_id = 5;

UPDATE buy_step INNER JOIN step USING (step_id)
SET date_step_beg = '2020-04-13'
WHERE name_step = 'Упаковка' AND buy_id = 5;
