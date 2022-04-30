#Создать таблицу author
CREATE TABLE author
(
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
);

#Заполнить таблицу author
INSERT INTO author (name_author)
VALUES
('Булгаков М.А.'),
('Достоевский Ф.М.'),
('Есенин С.А.'),
('Пастернак Б.Л.');

#Создать таблицу genre
CREATE TABLE genre
(
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name_genre VARCHAR(50)
);

#Создать таблицу book.
#Будем считать, что при удалении автора из таблицы author, должны удаляться все записи о книгах из таблицы book, написанные этим автором.
#А при удалении жанра из таблицы genre для соответствующей записи book установить значение Null в столбце genre_id.
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author_id INT NOT NULL,
    genre_id INT,
    price DECIMAL(8,2),
    amount INT,
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
);

#ЗАПРОСЫ НА ВЫБОРКУ
#Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.
SELECT title, name_genre, price
FROM
    genre INNER JOIN book
    ON genre.genre_id = book.genre_id
WHERE amount > 8
ORDER BY price DESC;

#Вывести все жанры, которые не представлены в книгах на складе.
SELECT name_genre
FROM genre LEFT JOIN book
     ON genre.genre_id = book.genre_id
WHERE book.genre_id IS NULL;

#Есть список городов, хранящийся в таблице city
#Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года.
#Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город, автора и дату проведения выставки.
#Последний столбец назвать Дата. Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.
SELECT name_city, name_author, (DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY)) AS Дата
FROM author, city
ORDER BY name_city, Дата DESC

#Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру,
#включающему слово «роман» в отсортированном по названиям книг виде.
SELECT name_genre, title, name_author
FROM
    author
    INNER JOIN  book ON author.author_id = book.author_id
    INNER JOIN genre ON genre.genre_id = book.genre_id
WHERE name_genre LIKE '%Роман%'
ORDER BY title;

#Посчитать количество экземпляров  книг каждого автора из таблицы author.
#Вывести тех авторов,  количество книг которых меньше 10,
#в отсортированном по возрастанию количества виде. Последний столбец назвать Количество.
SELECT name_author, SUM(amount) AS Количество
FROM author LEFT JOIN book
    ON author.author_id = book.author_id
GROUP BY name_author
HAVING Количество < 10 OR Количество IS NULL
ORDER BY Количество;

#Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре.
#Поскольку у нас в таблицах так занесены данные, что у каждого автора книги только в одном жанре,  для этого запроса внесем изменения в таблицу book.
#Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).
SELECT name_author
FROM author JOIN book
    ON author.author_id = book.author_id
GROUP BY name_author
HAVING COUNT( DISTINCT(genre_id))=1

#Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книг),
#написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде.
#Самым популярным считать жанр, общее количество экземпляров книг которого на складе максимально.
SELECT  title, name_author, name_genre, price, amount
FROM
    author
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON  book.genre_id = genre.genre_id
WHERE genre.genre_id IN
         (/* выбираем автора, если он пишет книги в самых популярных жанрах*/
          SELECT query_in_1.genre_id
          FROM
              ( /* выбираем код жанра и количество произведений, относящихся к нему */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
               )query_in_1
          INNER JOIN
              ( /* выбираем запись, в которой указан код жанр с максимальным количеством книг */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
                ORDER BY sum_amount DESC
                LIMIT 1
               ) query_in_2
          ON query_in_1.sum_amount= query_in_2.sum_amount
         )
ORDER BY title;

#В таблице supply занесена информация о книгах, поступивших на склад.
#Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,
#вывести их название и автора, а также посчитать общее количество экземпляров книг в таблицах supply и book,
#столбцы назвать Название, Автор  и Количество.
SELECT supply.title AS Название, supply.author AS Автор, supply.amount+book.amount AS Количество
FROM author
    INNER JOIN book USING (author_id)
    INNER JOIN supply ON book.title = supply.title
                         and book.price = supply.price
                         and author.name_author = supply.author;

#ЗАПРОСЫ НА КОРРЕКТИРОВКУ
#Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),
#необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену.
#А в таблице  supply обнулить количество этих книг
UPDATE book
     INNER JOIN author ON author.author_id = book.author_id
     INNER JOIN supply ON book.title = supply.title
                         and supply.author = author.name_author
SET book.amount = book.amount + supply.amount,
    book.price = (book.price*book.amount+supply.price*supply.amount)/(book.amount+supply.amount),
    supply.amount = 0
WHERE book.price <> supply.price;

#Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все данные из таблицы author.
#Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.
INSERT INTO author(name_author)
SELECT supply.author
FROM
    author
    RIGHT JOIN supply on author.name_author = supply.author
WHERE name_author IS Null;

#Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса.
#Затем вывести для просмотра таблицу book.
INSERT INTO book(title, author_id, price, amount)
SELECT title, author_id, price, amount
FROM
    author
    INNER JOIN supply ON author.name_author = supply.author
WHERE amount <> 0;
SELECT * FROM book;

#Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» Стивенсона - «Приключения».
#(Использовать два запроса).
UPDATE book
SET genre_id =
      (
       SELECT genre_id
       FROM genre
       WHERE name_genre = 'Поэзия'
      )
WHERE book_id = 6 OR book_id = 10;

UPDATE book
SET genre_id =
      (
       SELECT genre_id
       FROM genre
       WHERE name_genre = 'Приключения'
      )
WHERE book_id = 11;

#Удалить всех авторов и все их книги, общее количество книг которых меньше 20.
DELETE FROM author
WHERE author_id  IN
  (
    SELECT author_id
    FROM book
    GROUP BY author_id
    HAVING SUM(amount)<20
  );

#Удалить все жанры, к которым относится меньше 4-х книг. В таблице book для этих жанров установить значение Null.
DELETE FROM genre
WHERE genre_id   IN
  (
    SELECT genre_id
    FROM book
    GROUP BY genre_id
    HAVING SUM(genre_id )<4
  );

#Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов.
#В запросе для отбора авторов использовать полное название жанра, а не его id.
DELETE FROM author
USING author INNER JOIN book USING (author_id) INNER JOIN genre USING (genre_id)
WHERE name_genre  = 'Поэзия';
