# Новоселов Александр БПИ191
* ## Задание 2(Вариант 19)
Требовалось разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B с заменой нулевых элементов, предшествующих первому отрицательному, единицей. 
В результате я разбил программу на 3 подпрограммы: ввод, замена элементов и копирование остальных, вывод. Процедуры ввода и вывода с незначительными измненениями взяты из программы, показанной на семинаре, где требовалось найти сумму элементов в массиве. Программа замены написана с нуля и во ее код:
![Исходный код программы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/task02/%D0%A4%D1%83%D0%BD%D0%BA%D1%86%D0%B8%D1%8F%20%D0%B7%D0%B0%D0%BC%D0%B5%D0%BD%D1%8B%20%D1%8D%D0%BB%D0%B5%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2.PNG)

Результат работы программы можно увидеть на этом скриншоте
![Результат работы программы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/task02/%D0%A0%D0%B5%D0%B7%D1%83%D0%BB%D1%8C%D1%82%D0%B0%D1%82%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%8B%20%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D1%8B.PNG)

***
***
***
* ## Задание 1
Первая и вторая программа взяты из [открытого репозитория](https://github.com/secana/Assembler-Examples/tree/master/FASM) с примерами. Последние три взяты из примеров, поставляемых с fasm. Все исходные коды можно найти в папке code
***
* ## Программа для определения четности числа 
Программа имеет консольный интерфейс и определяет является ли введенное число четным.
![Программа и результат работы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Loop.PNG)
Т.к. программа достаточно проста и изменить в ней можно только строку, которая просит ввести число пользователем, то перейдем к следующему примеру.
***
* ## Простой калькулятор
Программа просит ввести пользователя знак и 2 числа, после чего выводит результат операции.
![Работа программы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/CalcCall.PNG)
***
* ## Программа выводящая простое окно с сообщением
Данный пример уже содержит графический интерфейс с простым диалоговым окном.
![Работа программы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/MessageBox.PNG)
***
* ## Простой блокнот
Программа реализует функционал простого блокнота.
- ![Работа программы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Minipad1.PNG)
Покопавшись в программе можно найти стркоу, создающую окно блокнота.
- ![Строка](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Minipad2.PNG)
 Если изменять поочередно цифры в середине строки, то можно заметить, что первые две отвечают за X и Y координаты левого верхнего угла на экране при первом появлении окна бллкнота, а последние две за высоту и ширину окна. 
- ![Результат изменения строки](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Minipad3.PNG)
***
* ## Программа для сокрытия иконки приложения на панели задач
При нажатии на кнопку hide иконка приложения на панели задач пропадает, а при нажатии на show появляется снова.
- ![Работа программы](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Taskbar.PNG)
Покопавшись в программе найдем блок, связанный с созданием кнопок в интерфейсе.
- ![Блок с кнопками](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Taskbar2.PNG)
Далее эмпирически выясним за что отвечает каждое из чисел в строках. Первые два за расположение кнопок, а третье и четвертое число за размер.
- ![Изменение кнопок](https://github.com/Freeezzzi/HSE_FCS_SE-ASM-1/blob/master/src/Taskbar3.PNG)
