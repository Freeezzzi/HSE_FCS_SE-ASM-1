#include <iostream>
#include <omp.h>
#include <cstdlib>
#include <ctime>
#include <vector>
using namespace std;
#define _rand(min, max) ( rand() % ((max) - (min) + 1) + (min) ) //возвращает случайное число из диапазона

std::vector<string> valentines;
std::string buffer = ""; //текущая валентинка
int best_valentives_note = -1; // номер лучшей валентинки 
int best_valentines_note_length = -1; //лучшая длина валентинки
omp_lock_t lck_buffer;
bool flag = false;

std::string generateString()
{
	//генерирует рандомную строку рандомной длины. Начальное значение задается перед вызовом(в клиенте)
	int length = _rand(5, 15);
	std::string message = "";
	for (int i = 0; i < length; ++i)
	{
		message += (char)_rand(32, 126);
	}
	return message;
}

bool check_valentines_note(string valentine)
{
	int count = 0;
	for (int i = 0; i < buffer.length(); ++i)
	{

		//выбираем только символы 
		if ((valentine[i] > 64 && valentine[i] < 91) || (valentine[i] > 96 && valentine[i] < 123)) //определим входит ли буква в латинский алфавит
		{
			++count;
		}
	}
	
	//узнаем подходит ли больше нам эта строка
	if (count > best_valentines_note_length)
	{
		best_valentines_note_length = count;
		return true;
	}
	return false;
}

void client(int num) {
	{
		srand(static_cast<unsigned int>(int(time(NULL)) ^ num));

		//сигналом что студентка прочитала валентинку, является свободный лок
		while (!omp_test_lock(&lck_buffer))
		{
			//skip
		}

		valentines[num] = generateString(); //сгенерируем строку
		std::cout << "I m student number " << num + 1 << " and my message is " << valentines[num] << std::endl; //выведем сгенерированное сообщение 

		omp_unset_lock(&lck_buffer);

		//Ждем пока студентка прочитает все валентинки
		while (!flag) {
		}

		if (best_valentives_note == num)
		{
			std::cout << "I am student " << num + 1 << " and i won the competition!" << std::endl;
		}
		//Если нет, то грустно плачем в одиночестве(
	}
}

void server(int param)
{
	int i = 0;
	while (i != param)
	{
		int position = 0;
		
		//студенты одноврменно обавляют в конец вектора свои валентинки, после прочтения они стираются, 
		//поэтому проверяем что в массиве есть хотя бы 1 непрочитанная валентинка
		for (; position < param; ++position)
		{
			if (valentines[position] != "")
			{
				break;
			}
		}

		//если в векторе еще нет валентинок(дошли до конца) то подождем еще
		if (position == param)
		{
			continue;
		}

		//пытаемся заблокировать лок
		while (!omp_test_lock(&lck_buffer)) {}

		buffer = valentines[position]; //считаем валентинку
		cout << "Server thread read message " << buffer << endl;
		
		//обработаем полученную валентинку
		if (check_valentines_note(buffer))
		{
			best_valentives_note = position;
		}
		valentines[position] = ""; //уберем ее из списка ожидания

		omp_unset_lock(&lck_buffer); //снимем лок, т.е. обозначим что закончили работу с общими данными

		i++;
	}
	flag = true; //сообщим другим потокам что все прочитано 
}

int main(int argc, char* argv[])
{
	//считаем кол-во студентов
	int number_of_students;
	std::cout << "Enter the number of admirers:" << std::endl;
	std::cin >> number_of_students;
	if (number_of_students <= 0)
	{
		std::cout << "Incorrect data! Try again" << std::endl;
		return 0;
	}
	
	srand(static_cast<unsigned int>(time(NULL))); //зададим случайное начальное значение
	std::cout << "A student has " << number_of_students << " admires" << std::endl;
	valentines = vector<string>(number_of_students);

	omp_init_lock(&lck_buffer); //создадим лок, чтобы 2 потока одноврменно не читали из буффера
	
#pragma omp parallel shared(lck_buffer, number_of_students) num_threads (number_of_students+1)
	{
		//запусстим n потоков для клиента
#pragma omp for nowait
		for (int i = 0; i < number_of_students; ++i)
		{
			client(i);
		}

		//запустим 1 поток для сервера
#pragma omp single nowait 
		{
			server(number_of_students);
		}
	}

	omp_destroy_lock(&lck_buffer);
}
