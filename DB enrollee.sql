#Предметная область
#Университет состоит из совокупности факультетов (школ). Поступление абитуриентов осуществляется на образовательные программы по результатам Единого государственного экзамена (ЕГЭ).
#Каждая образовательная программа относится к определенному факультету, для нее определены необходимые для поступления предметы ЕГЭ,
#минимальный балл по этим предметам, а также план набора (количество мест) на образовательную программу.

#В приемную комиссию абитуриенты подают заявления на образовательную программу, каждый абитуриент может выбрать несколько образовательных программ (но не более трех).
#В заявлении указывается фамилия, имя, отчество абитуриента, а также его достижения: получил ли он медаль за обучение в школе, имеет ли значок ГТО и пр.
#При этом за каждое достижение определен дополнительный балл. Абитуриент предоставляет сертификат с результатами сдачи  ЕГЭ.
#Если абитуриент выбирает образовательную программу, то у него обязательно должны быть сданы предметы, определенные на эту программу,
#причем балл должен быть не меньше минимального по данному предмету.

#Зачисление абитуриентов осуществляется так: сначала вычисляется сумма баллов по предметам на каждую образовательную программу, добавляются баллы достижения,
#затем абитуриенты сортируются в порядке убывания суммы баллов и отбираются первые по количеству мест, определенному планом набора.
CREATE DATABASE enrollee;

CREATE TABLE department (
    `department_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_department` VARCHAR(30)
);
INSERT INTO department (`department_id`, `name_department`)
VALUES
  (1, 'Инженерная школа'),
  (2, 'Школа естественных наук');

CREATE TABLE subject (
    `subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_subject` VARCHAR(30)
);
INSERT INTO subject (`subject_id`, `name_subject`)
VALUES
  (1, 'Русский язык'),
  (2, 'Математика'),
  (3, 'Физика'),
  (4, 'Информатика');

#Таблица program (в последнем столбце указан план набора абитуриентов на образовательную программу):
CREATE TABLE program (
    `program_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_program` VARCHAR(50),
    `department_id` INT,
    `plan` INT,
    FOREIGN KEY (`department_id`) REFERENCES `department`(`department_id`) ON DELETE CASCADE
);
INSERT INTO program (`program_id`, `name_program`, `department_id`, `plan`)
VALUES
  (1, 'Прикладная математика и информатика', 2, 2),
  (2, 'Математика и компьютерные науки', 2, 1),
  (3, 'Прикладная механика', 1, 2),
  (4, 'Мехатроника и робототехника', 1, 3);

CREATE TABLE enrollee (
    `enrollee_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_enrollee` VARCHAR(50)
);
INSERT INTO enrollee (`enrollee_id`, `name_enrollee`)
VALUES
  (1, 'Баранов Павел'),
  (2, 'Абрамова Катя'),
  (3, 'Семенов Иван'),
  (4, 'Яковлева Галина'),
  (5, 'Попов Илья'),
  (6, 'Степанова Дарья');

#Таблица achievement (таблица включает все достижения, которые учитываются при поступлении в университет,
#в последнем столбце указывается количество баллов, которое добавляется к сумме баллов по предметам ЕГЭ при расчете общего балла абитуриента):
CREATE TABLE achievement (
    `achievement_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_achievement` VARCHAR(30),
    `bonus` INT
);
INSERT INTO achievement (`achievement_id`, `name_achievement`, `bonus`)
VALUES
  (1, 'Золотая медаль', 5),
  (2, 'Серебряная медаль', 3),
  (3, 'Золотой значок ГТО', 3),
  (4, 'Серебряный значок ГТО', 1);

#Таблица enrollee_achievement(в таблице содержится информация о том, какие достижения имеют абитуриенты):
CREATE TABLE enrollee_achievement (
    `enrollee_achiev_id` INT PRIMARY KEY AUTO_INCREMENT,
    `enrollee_id` INT,
    `achievement_id` INT,
    FOREIGN KEY (`enrollee_id`) REFERENCES `enrollee`(`enrollee_id`) ON DELETE CASCADE,
    FOREIGN KEY (`achievement_id`) REFERENCES `achievement`(`achievement_id`) ON DELETE CASCADE
);
INSERT INTO enrollee_achievement (`enrollee_achiev_id`, `enrollee_id`, `achievement_id`)
VALUES
  (1, 1, 2),
  (2, 1, 3),
  (3, 3, 1),
  (4, 4, 4),
  (5, 5, 1),
  (6, 5, 3);

#Таблица program_subject(в таблице указано, какие предметы ЕГЭ необходимы для поступления на каждую программу,
#в последнем столбце – минимальный балл по каждому предмету для образовательной программы):
CREATE TABLE program_subject (
    `program_subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `program_id` INT,
    `subject_id` INT,
    `min_result` INT,
    FOREIGN KEY (`program_id`) REFERENCES `program`(`program_id`)  ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subject`(`subject_id`) ON DELETE CASCADE
);
INSERT INTO program_subject (`program_subject_id`, `program_id`, `subject_id`, `min_result`)
VALUES
  (1, 1, 1, 40),
  (2, 1, 2, 50),
  (3, 1, 4, 60),
  (4, 2, 1, 30),
  (5, 2, 2, 50),
  (6, 2, 4, 60),
  (7, 3, 1, 30),
  (8, 3, 2, 45),
  (9, 3, 3, 45),
  (10, 4, 1, 40),
  (11, 4, 2, 45),
  (12, 4, 3, 45);

#Таблица program_enrollee(таблица включает информацию, на какую образовательную программу хочет поступить абитуриент):
CREATE TABLE program_enrollee (
    `program_enrollee_id` INT PRIMARY KEY AUTO_INCREMENT,
    `program_id` INT,
    `enrollee_id` INT,
    FOREIGN KEY (`program_id`) REFERENCES `program`(`program_id`) ON DELETE CASCADE,
    FOREIGN KEY (`enrollee_id`) REFERENCES enrollee(`enrollee_id`) ON DELETE CASCADE
);
INSERT INTO program_enrollee (`program_enrollee_id`, `program_id`, `enrollee_id`)
VALUES
  (1, 3, 1),
  (2, 4, 1),
  (3, 1, 1),
  (4, 2, 2),
  (5, 1, 2),
  (6, 1, 3),
  (7, 2, 3),
  (8, 4, 3),
  (9, 3, 4),
  (10, 3, 5),
  (11, 4, 5),
  (12, 2, 6),
  (13, 3, 6),
  (14, 4, 6);

#Таблица enrollee_subject(баллы ЕГЭ каждого абитуриента):
CREATE TABLE enrollee_subject (
    `enrollee_subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `enrollee_id` INT,
    `subject_id` INT,
    `result` INT,
    FOREIGN KEY (`enrollee_id`) REFERENCES `enrollee`(`enrollee_id`) ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subject`(`subject_id`) ON DELETE CASCADE
);
INSERT INTO enrollee_subject (`enrollee_subject_id`, `enrollee_id`, `subject_id`, `result`)
VALUES
  (1, 1, 1, 68),
  (2, 1, 2, 70),
  (3, 1, 3, 41),
  (4, 1, 4, 75),
  (5, 2, 1, 75),
  (6, 2, 2, 70),
  (7, 2, 4, 81),
  (8, 3, 1, 85),
  (9, 3, 2, 67),
  (10, 3, 3, 90),
  (11, 3, 4, 78),
  (12, 4, 1, 82),
  (13, 4, 2, 86),
  (14, 4, 3, 70),
  (15, 5, 1, 65),
  (16, 5, 2, 67),
  (17, 5, 3, 60),
  (18, 6, 1, 90),
  (19, 6, 2, 92),
  (20, 6, 3, 88),
  (21, 6, 4, 94);

#Вывести абитуриентов, которые хотят поступать на образовательную программу
#«Мехатроника и робототехника» в отсортированном по фамилиям виде.
SELECT name_enrollee
FROM enrollee
    INNER JOIN program_enrollee USING(enrollee_id)
    INNER JOIN program USING(program_id)
WHERE name_program = 'Мехатроника и робототехника'
ORDER BY name_enrollee;

#Вывести образовательные программы, на которые для поступления необходим предмет «Информатика».
#Программы отсортировать в обратном алфавитном порядке.
SELECT name_program
FROM subject
    INNER JOIN program_subject USING(subject_id)
    INNER JOIN program USING(program_id)
WHERE name_subject = 'Информатика'
ORDER BY name_program DESC;

#Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, минимальное и среднее значение баллов по предмету ЕГЭ.
#Вычисляемые столбцы назвать Количество, Максимум, Минимум, Среднее.
#Информацию отсортировать по названию предмета в алфавитном порядке, среднее значение округлить до одного знака после запятой.
SELECT name_subject, COUNT(enrollee_id) AS Количество, MAX(result) AS Максимум, MIN(result) AS  Минимум, ROUND(AVG(result), 1) AS  Среднее
FROM subject
    INNER JOIN enrollee_subject USING(subject_id)
GROUP BY  name_subject
ORDER BY name_subject;

#Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету больше или равен 40 баллам.
#Программы вывести в отсортированном по алфавиту виде.
SELECT name_program
FROM program
    INNER JOIN program_subject USING(program_id)
GROUP BY name_program
HAVING MIN(min_result) >= 40
ORDER BY name_program;

#Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной.
SELECT name_program, plan
FROM program
WHERE plan =
    (
      SELECT plan
      FROM program
      ORDER BY plan DESC
      LIMIT 1
    );

#Посчитать, сколько дополнительных баллов получит каждый абитуриент. Столбец с дополнительными баллами назвать Бонус.
#Информацию вывести в отсортированном по фамилиям виде.
SELECT name_enrollee, IF(SUM(bonus) IS NULL, 0, SUM(bonus)) AS Бонус
FROM enrollee
    LEFT JOIN enrollee_achievement USING(enrollee_id)
    LEFT JOIN achievement USING(achievement_id)
GROUP BY name_enrollee
ORDER BY name_enrollee;

#Выведите сколько человек подало заявление на каждую образовательную программу и конкурс на нее
#(число поданных заявлений деленное на количество мест по плану), округленный до 2-х знаков после запятой.
#В запросе вывести название факультета, к которому относится образовательная программа,
#название образовательной программы, план набора абитуриентов на образовательную программу (plan),
#количество поданных заявлений (Количество) и Конкурс. Информацию отсортировать в порядке убывания конкурса.
SELECT name_department, name_program, plan, COUNT(enrollee_id) AS Количество,  ROUND(COUNT(enrollee_id)/plan, 2) AS Конкурс
FROM department
    INNER JOIN program USING(department_id)
    INNER JOIN program_enrollee USING(program_id)
GROUP BY name_department, name_program, plan
ORDER BY Конкурс DESC;

#Вывести образовательные программы, на которые для поступления необходимы предмет «Информатика» и «Математика»
#в отсортированном по названию программ виде.
SELECT name_program
FROM program
    INNER JOIN program_subject USING(program_id)
    INNER JOIN subject USING(subject_id)
WHERE name_subject = 'Математика' OR name_subject = 'Информатика'
GROUP BY name_program
HAVING COUNT(name_program)=2
ORDER BY name_program;

#Посчитать количество баллов каждого абитуриента на каждую образовательную программу, на которую он подал заявление, по результатам ЕГЭ.
#В результат включить название образовательной программы, фамилию и имя абитуриента, а также столбец с суммой баллов, который назвать itog.
#Информацию вывести в отсортированном сначала по образовательной программе, а потом по убыванию суммы баллов виде.
SELECT name_program, name_enrollee, SUM(result) AS itog
FROM enrollee
    INNER JOIN program_enrollee ON program_enrollee.enrollee_id=enrollee.enrollee_id
    INNER JOIN program ON program_enrollee.program_id=program.program_id
    INNER JOIN program_subject ON program.program_id=program_subject.program_id
    INNER JOIN subject ON program_subject.subject_id=subject.subject_id
    INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id  and enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY name_program, name_enrollee
ORDER BY name_program, itog DESC;

#Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту образовательную программу,
#но не могут быть зачислены на нее. Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ,
#необходимым для поступления на эту образовательную программу, меньше минимального балла.
#Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.

#Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы «Прикладная механика» минимальный балл по этому предмету определен в 45 баллов.
#Следовательно, абитуриент на данную программу не может поступить.
SELECT name_program, name_enrollee
FROM enrollee
    INNER JOIN program_enrollee ON program_enrollee.enrollee_id=enrollee.enrollee_id
    INNER JOIN program ON program_enrollee.program_id=program.program_id
    INNER JOIN program_subject ON program.program_id=program_subject.program_id
    INNER JOIN subject ON program_subject.subject_id=subject.subject_id
    INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id  and enrollee_subject.enrollee_id = enrollee.enrollee_id
WHERE result < min_result
ORDER BY name_program;

#Создать вспомогательную таблицу applicant,  куда включить id образовательной программы, id абитуриента, сумму баллов абитуриентов (столбец itog)
#в отсортированном сначала по id образовательной программы, а потом по убыванию суммы баллов виде (использовать запрос из предыдущего урока).
CREATE TABLE applicant AS
SELECT program.program_id, enrollee.enrollee_id, SUM(result) AS itog
FROM enrollee
    INNER JOIN program_enrollee ON program_enrollee.enrollee_id=enrollee.enrollee_id
    INNER JOIN program ON program_enrollee.program_id=program.program_id
    INNER JOIN program_subject ON program.program_id=program_subject.program_id
    INNER JOIN subject ON program_subject.subject_id=subject.subject_id
    INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id  and enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY program_id, enrollee_id
ORDER BY program_id, itog DESC;

#Из таблицы applicant, созданной на предыдущем шаге, удалить записи, если абитуриент на выбранную образовательную программу не набрал минимального балла
#хотя бы по одному предмету.
DELETE FROM applicant
USING applicant
    INNER JOIN enrollee ON applicant.enrollee_id=enrollee.enrollee_id
    INNER JOIN program_enrollee ON program_enrollee.enrollee_id=enrollee.enrollee_id
    INNER JOIN program ON program_enrollee.program_id=program.program_id AND applicant.program_id=program.program_id
    INNER JOIN program_subject ON program.program_id=program_subject.program_id
    INNER JOIN subject ON program_subject.subject_id=subject.subject_id
    INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id  and enrollee_subject.enrollee_id = enrollee.enrollee_id
WHERE result < min_result;

#Повысить итоговые баллы абитуриентов в таблице applicant на значения дополнительных баллов (использовать запрос из предыдущего урока).
UPDATE applicant INNER JOIN
(
SELECT enrollee_id, IF(SUM(bonus) IS NULL, 0, SUM(bonus)) AS bonus
FROM enrollee
    LEFT JOIN enrollee_achievement USING(enrollee_id)
    LEFT JOIN achievement USING(achievement_id)
GROUP BY enrollee_id
) AS bonus
ON applicant.enrollee_id = bonus.enrollee_id
SET itog = itog+bonus;

#Поскольку при добавлении дополнительных баллов, абитуриенты по каждой образовательной программе могут следовать не в порядке убывания суммарных баллов,
#необходимо создать новую таблицу applicant_order на основе таблицы applicant. При создании таблицы данные нужно отсортировать сначала по id образовательной программы,
#потом по убыванию итогового балла. А таблицу applicant, которая была создана как вспомогательная, необходимо удалить.
CREATE TABLE applicant_order AS
SELECT *
FROM applicant
ORDER BY program_id, itog DESC;

DROP TABLE applicant;

#Включить в таблицу applicant_order новый столбец str_id целого типа , расположить его перед первым.
ALTER TABLE applicant_order ADD str_id INT FIRST;

#Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов, которая начинается с 1 для каждой образовательной программы.
SET @num_pr := 0;
SET @row_num := 1;

UPDATE applicant_order INNER JOIN
(
SELECT *,
    IF(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1)
AS str_num,
    @num_pr := program_id AS add_var
FROM applicant_order
) AS num
ON applicant_order.program_id = num.program_id AND applicant_order.enrollee_id = num.enrollee_id
SET applicant_order.str_id = num.str_num;

#Создать таблицу student,  в которую включить абитуриентов, которые могут быть рекомендованы к зачислению  в соответствии с планом набора.
#Информацию отсортировать сначала в алфавитном порядке по названию программ, а потом по убыванию итогового балла.
CREATE TABLE student AS
SELECT name_program, name_enrollee, itog
FROM program
    INNER JOIN applicant_order USING(program_id)
    INNER JOIN enrollee USING(enrollee_id)
WHERE str_id <= plan
ORDER BY name_program, itog DESC;
