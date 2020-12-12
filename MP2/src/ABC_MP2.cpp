// ABC_MP2.cpp : Этот файл содержит функцию "main". Здесь начинается и заканчивается выполнение программы.

#include <iostream>
#include <cstdlib>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <vector>
#include <ctime>
#include <fstream>
using namespace std;

#define _rand(min, max) ( rand() % ((max) - (min) + 1) + (min) ) //возвращает случайное число из диапазона [min,max]

std::mutex honey_mutex, write_mutex, print_mutex; // мютексы для лока блоков кода 
std::condition_variable cond_honey, conds, condp; // используется для сигнализации
int count_honey = 0; // кол-во меда в улье
int count_bees = 0; // кол-во пчел в улье
int N;              //общее кол-во пчел в задаче
bool isEnd = false; //флаг что потоки должны завершать свою работу
ofstream out; // поток для выводе лога работы программы
auto start = chrono::system_clock::now(); // в main переменной назначится время начала выполнения потоков.

void bee(int num) {
	srand(static_cast<unsigned int>(int(time(NULL)) ^ num));

	while (!isEnd)
	{
		//пчела остается в улье если там нет других пчел, или с такой вероятностью, что мат. ожидание СВ = 3 
		//это сделано для сбалансированности задачи, иначе при const вероятности при больших N у винни-пуха не будет шансов выкрасть мед
		if (count_bees == 1 || _rand(0, N) < 3)
		{
			//сторожит 
			int time_guard = _rand(100, 500);
			{
				unique_lock<std::mutex> locker(print_mutex);
				auto end = std::chrono::system_clock::now();
				std::chrono::duration<double> elapsed_seconds = end - start;
				out << "Time " << elapsed_seconds.count() <<": bee " << num << " guards the hive for " << time_guard << " ms." << endl;
			}
			this_thread::sleep_for(chrono::milliseconds(time_guard));
			//по истечению времени снова подумывает вылететь
			continue;
		}
		else {
			//полетела собирать мёд
			int time_collect = _rand(200, 600);
			count_bees--;
			{
				unique_lock<std::mutex> locker(print_mutex);
				auto end = std::chrono::system_clock::now();
				std::chrono::duration<double> elapsed_seconds = end - start;
				out << "Time " << elapsed_seconds.count() << ": bee " << num << " flew to collect honey for " << time_collect << " ms." << endl;
			}
			this_thread::sleep_for(chrono::milliseconds(time_collect));

			//пытается залететь обратно в улей
			if (count_honey == 30)
			{
				//пчела ждет 1 секунду и по истечению времени, если меда все еще больше чем нужно, залетает в улей без свеого меда
				this_thread::sleep_for(1s);
				if (count_honey != 30)
				{
					count_honey++;
					unique_lock<std::mutex> locker(print_mutex);
					auto end = std::chrono::system_clock::now();
					std::chrono::duration<double> elapsed_seconds = end - start;
					out << "Time " << elapsed_seconds.count() << ": bee " << num << " flew back with honey." << endl;
				}
			}
			else {
				count_honey++;
				unique_lock<std::mutex> locker(print_mutex);
				auto end = std::chrono::system_clock::now();
				std::chrono::duration<double> elapsed_seconds = end - start;
				out << "Time " << elapsed_seconds.count() << ": bee " << num << " flew back with honey." << endl;
			}
			count_bees++;
		}

		if (count_honey >= 15)
		{
			cond_honey.notify_one();
			unique_lock<std::mutex> locker(print_mutex);
			auto end = std::chrono::system_clock::now();
			std::chrono::duration<double> elapsed_seconds = end - start;
			out << "Time " << elapsed_seconds.count() << ": bee " << num << " the hive have enough honey." << endl;
		}
	}

}

void beer(int num) {
	int beer_honey = 0;
	while (!isEnd)
	{
		std::unique_lock<std::mutex> locker(honey_mutex);
		while (count_honey < 15) // от ложных пробуждений
			cond_honey.wait(locker);
		{
			unique_lock<std::mutex> locker(print_mutex);
			auto end = std::chrono::system_clock::now();
			std::chrono::duration<double> elapsed_seconds = end - start;
			out << "Time " << elapsed_seconds.count() << ": Winnie the Pooh trying to steal honey." << endl;
			out << "Time " << elapsed_seconds.count() << ": Winnie the Pooh: " << count_bees << " bees in the hive." << endl;
		}
		if (count_bees < 3)
		{
			beer_honey += count_honey;
			count_honey = 0;
			{
				unique_lock<std::mutex> locker(print_mutex);
				auto end = std::chrono::system_clock::now();
				std::chrono::duration<double> elapsed_seconds = end - start;
				out << "Time " << elapsed_seconds.count() << ": Winnie the Pooh stole honey." << endl;
			}
			this_thread::sleep_for(2s);
		}
		else {
			{
				unique_lock<std::mutex> locker(print_mutex);
				auto end = std::chrono::system_clock::now();
				std::chrono::duration<double> elapsed_seconds = end - start;
				out << "Time " << elapsed_seconds.count() << ": Winnie the Pooh: too many bees in the hive." << endl;
			}
			this_thread::sleep_for(1s);
		}
	}

	{
		unique_lock<std::mutex> locker(print_mutex);
		out << "Winnie the Pooh: stole " << beer_honey << " of honey." << endl;
	}
}

int main()
{
	//Соаздаем поток для записи в файл
	out.open("log.txt");
	cout << "Enter the number of bees:" << endl;
	cin >> N;
	if (N <= 0)
	{
		cout << "Incorrect data! Try again" << endl;
		return 0;
	}
	count_bees = N; //все пчелы изначально начинают в улье 

	//получим время работы программы
	long time;
	cout << "Enter the programme run time in seconds:" << endl;
	cin >> time;
	if (time <= 0)
	{
		cout << "Incorrect data! Try again" << endl;
		return 0;
	}

	cout << "All output data will be in log.txt file in working directory after end of programm" << endl;

	start = chrono::system_clock::now();

	std::vector<std::thread> bees_treads; //храним ссылки на потоки, чтобы они не вышли из области видимости и не уничтожились раньше времени
	std::thread beer_thread = thread(beer, N); //создадим поток сервера

	int i = 1;
	for (; i <= N; ++i)
	{
		bees_treads.push_back(thread(bee, i)); //заполним массив потоков
	}

	//отправим главный поток в спячку на заданное кол-во секунд
	const auto seconds = chrono::seconds(time);
	this_thread::sleep_for(seconds);
	isEnd = true;

	for (int i = 0; i < N; ++i)
	{
		bees_treads[i].join();
	}

	beer_thread.join(); //чтобы поток был безопасен для удаления при выходе из области видимости
}