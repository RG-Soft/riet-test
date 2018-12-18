// Функция возвращает список с наборами прав, доступными текущему пользователю
//
// Параметры:
//  нет.
//
// Возвращаемое значение:
//  Список значений с доступными ролями пользователя
//
Функция ПолучитьСписокНабораПрав() Экспорт

	НаборДоступныхРолейПользователя = Новый СписокЗначений;
	
	ЗначенияПеречисления = Метаданные.Перечисления.НаборПравПользователей.ЗначенияПеречисления;
	
	КоличествоНаборовПрав = Перечисления.НаборПравПользователей.Количество();
	Для а = 0 По КоличествоНаборовПрав - 1 Цикл
		Если РольДоступна(Строка(ЗначенияПеречисления[а].Имя)) ИЛИ РольДоступна(Строка(ЗначенияПеречисления[а].Имя)+"СОграничениемПравДоступа") Тогда
			НаборДоступныхРолейПользователя.Добавить(Перечисления.НаборПравПользователей[а]);
		КонецЕсли;
	КонецЦикла;

	Возврат НаборДоступныхРолейПользователя;

КонецФункции // ПолучитьСписокНабораПрав()

// Возвращает договор контрагента, если организация, указанная
// в данном договоре доступна пользователю
Функция ДоступныйДоговорКонтрагента(ДоговорСсылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДоговорСсылка", ДоговорСсылка);
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ДоговорыКонтрагентов.Организация
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.Ссылка = &ДоговорСсылка";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ДоговорКонтрагента = Выборка.Договор;
		
	Иначе
		ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	КонецЕсли;
	
	Возврат ДоговорКонтрагента;
	
КонецФункции // ДоступныйДоговорКонтрагента()

// Функция возвращает список значений права, установленных для пользователя.
// Если количество значений меньше количество доступных ролей, то возвращается значение по умолчанию
//
// Параметры:
//  Право               - право, для которого определяются значения
//  ЗначениеПоУмолчанию - значение по умолчанию для передаваемого права (возвращается в случае
//                        отсутствия значений в регистре сведений)
//
// Возвращаемое значение:
//  Список всех значений, установленных наборам прав (ролям), доступных пользователю
//
Функция ПолучитьЗначениеПраваДляТекущегоПользователя(Право, ЗначениеПоУмолчанию = Неопределено) Экспорт

	ВозвращаемыеЗначения = Новый СписокЗначений;
	СписокНабораПрав = ПолучитьСписокНабораПрав();

	Запрос = Новый Запрос;

	Запрос.УстановитьПараметр("НаборПрав"        , СписокНабораПрав);
	Запрос.УстановитьПараметр("ПравоПользователя", Право);

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Значение
	|ИЗ
	|	РегистрСведений.ЗначенияПравПользователя КАК РегистрЗначениеПрав
	|
	|ГДЕ
	|	Право = &ПравоПользователя
	| И НаборПрав В(&НаборПрав)
	|
	|";

	Выборка = Запрос.Выполнить().Выбрать();

	Если Выборка.Количество() < СписокНабораПрав.Количество() Тогда
		ВозвращаемыеЗначения.Добавить(ЗначениеПоУмолчанию);
	КонецЕсли;

	Пока Выборка.Следующий() Цикл
		Если ВозвращаемыеЗначения.НайтиПоЗначению(Выборка.Значение) = Неопределено Тогда
			ВозвращаемыеЗначения.Добавить(Выборка.Значение);
		КонецЕсли;
	КонецЦикла;

	Возврат ВозвращаемыеЗначения;

КонецФункции // ПолучитьЗначениеПраваДляТекущегоПользователя()

// Процедура проверяет возможность запуска ИБ с определенными для текущего
// пользователя доступными ролями
//
Процедура ПроверитьВозможностьРаботыПользователя(Отказ) Экспорт

	Если НЕ ПолныеПрава.ЕстьДоступныеПраваДляЗапускаКонфигурации() Тогда
		Отказ = Истина;
		#Если Клиент Тогда
		Предупреждение("У текущего пользователя нет доступных ролей, для запуска информационной базы.", 10, "Недостаточно прав доступа");
		#КонецЕсли
	КонецЕсли; 
	
КонецПроцедуры

// Функция возвращает значение по умолчанию для передаваемого пользователя и настройки.
//
// Параметры:
//  Пользователь - текущий пользователь программы
//  Настройка    - признак, для которого возвращается значение по умолчанию
//
// Возвращаемое значение:
//  Значение по умолчанию для настройки.
//
Функция ПолучитьЗначениеПоУмолчанию(Пользователь, Настройка) Экспорт

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Пользователь", Пользователь);
	Запрос.УстановитьПараметр("Настройка"   , ПланыВидовХарактеристик.НастройкиПользователей[Настройка]);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Значение
	|ИЗ
	|	РегистрСведений.НастройкиПользователей КАК РегистрЗначениеПрав
	|
	|ГДЕ
	|	Пользователь = &Пользователь
	| И Настройка    = &Настройка";

	Выборка = Запрос.Выполнить().Выбрать();

	ПустоеЗначение = ПланыВидовХарактеристик.НастройкиПользователей[Настройка].ТипЗначения.ПривестиЗначение();

	Если Выборка.Количество() = 0 Тогда
		
		Возврат ПустоеЗначение;

	ИначеЕсли Выборка.Следующий() Тогда

		Если ОбщегоНазначения.ЗначениеНеЗаполнено(Выборка.Значение) Тогда
			Возврат ПустоеЗначение;
		Иначе
			Возврат Выборка.Значение;
		КонецЕсли;

	Иначе
		Возврат ПустоеЗначение;

	КонецЕсли;

КонецФункции // ПолучитьЗначениеПоУмолчанию()

// Процедура записывает значение по умолчанию для передаваемого пользователя и настройки.
//
// Параметры:
//  Пользователь - текущий пользователь программы
//  Настройка    - признак, для которого записывается значение по умолчанию
//  Значение     - значение по умолчанию
//
// Возвращаемое значение:
//  Нет
//
Процедура УстановитьЗначениеПоУмолчанию(Пользователь, Настройка, Значение) Экспорт

	СсылкаНастройки = ПланыВидовХарактеристик.НастройкиПользователей[Настройка];
	МенеджерЗаписи = РегистрыСведений.НастройкиПользователей.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Пользователь = Пользователь;
	МенеджерЗаписи.Настройка = СсылкаНастройки;
	МенеджерЗаписи.Значение = Значение;
	МенеджерЗаписи.Записать(Истина);

КонецПроцедуры // ПолучитьЗначениеПоУмолчанию()

// Процедура инициализирует глобальную переменную глТекущийПользователь.
// Переменная содержит ссылку на элемент справочника "Пользователи", 
// соответствующий текущему пользователю информационной базы.
//
// Параметры:
//  Нет.
//
Функция ОпределитьТекущегоПользователя(глТекущийПользователь, ОписаниеОшибкиОпределенияПользователя = "") Экспорт

	ИмяПользователя = ИмяПользователя();
	
	Если ПустаяСтрока(ИмяПользователя) Тогда
		// пользователь не авторизовался
		ИмяПользователя = "НеАвторизован";
		
	КонецЕсли;

	глТекущийПользователь = Справочники.Пользователи.НайтиПоКоду(ИмяПользователя);

	Если ОбщегоНазначения.ЗначениеНеЗаполнено(глТекущийПользователь) Тогда
		
		// не нашли пользователя
		// попытаемся создать нового пользователя - не авторизован, если есть полные права
		Если НЕ РольДоступна("ПолныеПрава") Тогда
			
			// не доступна роль полные права - ничего сделать не удасться
			ОписаниеОшибкиОпределенияПользователя = "Пользователь : " + ИмяПользователя + " не был найден в справочнике пользователей.
			|Вход в программу возможен только при наличии роли ""Полные права"" или при наличии пользователя в справочнике.";

			Возврат Ложь;
			
		КонецЕсли;		
		
		ОбъектПользователь = Справочники.Пользователи.СоздатьЭлемент();

		ОбъектПользователь.Код          = ИмяПользователя;
		ОбъектПользователь.Наименование = "Не авторизован";

		Попытка
			
			ОбъектПользователь.Записать();
			
		Исключение
			
			ОписаниеОшибкиОпределенияПользователя = "Пользователь : " + ИмяПользователя + " не был найден в справочнике пользователей. Возникла ошибка при добавлении пользователя в справочник.
			|" + ОписаниеОшибки();
			Возврат Ложь;
			
		КонецПопытки;
		
		глТекущийПользователь = ОбъектПользователь.Ссылка;
		
		Набор = РегистрыСведений.НастройкиПользователей.СоздатьНаборЗаписей();
		Набор.Отбор.Пользователь.Использование = Истина;
		Набор.Отбор.Пользователь.Значение      = глТекущийПользователь;
		
		// Инициализируем признак учета по всем организациям
		Режим = Истина;
		
		// установим пользователю основную организацию
		Если РольДоступна(Метаданные.Роли.ПолныеПрава) Тогда
			
			Запрос = Новый Запрос();
			Запрос.Текст = "
			|ВЫБРАТЬ
			|	Организации.Ссылка
			|ИЗ
			|	Справочник.Организации КАК Организации";
			Выборка = Запрос.Выполнить().Выбрать();

			КоличествоЗаписейВВыборке = Выборка.Количество();
			
			Если КоличествоЗаписейВВыборке = 1 Тогда

				// выбирать не из чего - запишем значения без лишних вопросов
				Выборка.Следующий();
				ОсновнаяОрганизация = Выборка.Ссылка;
					
			ИначеЕсли КоличествоЗаписейВВыборке > 0 Тогда

				ФормаВыбора = ПолучитьОбщуюФорму("УправлениеУчетомПоОрганизациям");

				СтруктураВозврата = ФормаВыбора.ОткрытьМодально();

				Если (СтруктураВозврата <> Неопределено) Тогда
					Режим               = СтруктураВозврата.Режим;
					ОсновнаяОрганизация = СтруктураВозврата.Организация;
				КонецЕсли;
                    					
				Если ОсновнаяОрганизация = Неопределено Тогда
					ОсновнаяОрганизация = Справочники.Организации.ПустаяСсылка()
				КонецЕсли;

			КонецЕсли;			

			Запись = Набор.Добавить();

			Запись.Пользователь = глТекущийПользователь;
			Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.ОсновнаяОрганизация;
			Запись.Значение     = ОсновнаяОрганизация;
			
		КонецЕсли;

		Запись = Набор.Добавить();
		
		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.ЗапрашиватьПодтверждениеПриЗакрытии;
		Запись.Значение     = Истина;

		Запись = Набор.Добавить();
		
		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.ПоказыватьВДокументахСчетаУчета;
		Запись.Значение     = Истина;
		
		Запись = Набор.Добавить();

		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.УчетПоВсемОрганизациям;
		Запись.Значение     = Режим;
		
		Запись = Набор.Добавить();

		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.ОсновнойОтветственный;
		Запись.Значение     = глТекущийПользователь;
		
		//РГ-Софт, Прокошева
		Запись = Набор.Добавить();

		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.УчетПоВсемОтветственным;
		Запись.Значение     = Режим;

		Запись = Набор.Добавить();
		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.ОсновнойОтветственный;
		Запись.Значение     = Справочники.Пользователи.ПустаяСсылка();

		Запись.Пользователь = глТекущийПользователь;
		Запись.Настройка    = ПланыВидовХарактеристик.НастройкиПользователей.УчетПоВсемИнвойсинговымЦентрам;
		Запись.Значение     = Режим;

		Попытка
			
			Набор.Записать();
			
		Исключение
			
			ОписаниеОшибкиОпределенияПользователя = "Ошибка при записи настроек нового пользователя.
				|" + ОписаниеОшибки();
			Возврат Ложь;
			
		КонецПопытки;
		
		#Если Клиент Тогда
			Сообщить("Пользователь зарегистрирован в справочнике пользователей.");
		#КонецЕсли
	    						
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ РАБОТЫ С ПОЛЬЗОВАТЕЛЯМИ БД

//Функция создает нового пользователя БД с настройками по умолчанию и возвращает его
Функция ДобавитьНовогоПользователяБД(ИмяПользователя, ПолноеИмя = Неопределено, СообщатьОДобавленииПользователя = Истина, ЗаписатьПользователяВБД = Истина) Экспорт
	
	НовыйПользователь = ПользователиИнформационнойБазы.СоздатьПользователя();
	НовыйПользователь.Имя = ИмяПользователя;
	НовыйПользователь.ПолноеИмя = ?(ОбщегоНазначения.ЗначениеНеЗаполнено(ПолноеИмя), ИмяПользователя, ПолноеИмя);
	
	НовыйПользователь.АутентификацияСтандартная = Истина;
	НовыйПользователь.ПоказыватьВСпискеВыбора = Истина;
	
	Если ЗаписатьПользователяВБД Тогда
		
		Попытка
			НовыйПользователь.Записать();
			#Если Клиент Тогда
			Если СообщатьОДобавленииПользователя Тогда
				Сообщить("В список пользователей БД добавлен пользователь с именем """ + ИмяПользователя + """");
			КонецЕсли;
			#КонецЕсли

		Исключение
		
			#Если Клиент Тогда
			Сообщить("Ошибка при добавлении пользователя в список пользователей БД """ + ИмяПользователя + """");
			#КонецЕсли
	
		КонецПопытки;
	
	КонецЕсли;	
	
	Возврат НовыйПользователь;
КонецФункции

// Функция по имени ищет пользователя БД, если не находит - создает нового и его возвращает
// Параметры:
//	ИмяПользователя - строка по которой ищется пользователь БД
//  ПолноеИмяПользователя - строка, при добавлении пользователя БД таким будет установлено полное имя пользователя
//	СообщатьОДобавленииПользователя - Булево, нужно ли сообщать о добавлении нового пользователя БД
//	ЗаписатьПользователяВБД - Нужно ли при добавлении пользователя записывать его
Функция НайтиПользователяБД(ИмяПользователя) Экспорт
	
	Если ИмяПользователя = "НеАвторизован" Тогда
		ПользовательИБ = Неопределено
	Иначе
		// ищем пользователя БД по имени
		Попытка
			ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователя);
		Исключение
			ПользовательИБ = Неопределено;
		КонецПопытки;
		
	КонецЕсли;
	
	Возврат ПользовательИБ;
КонецФункции

// Функция дополняет ИМЯ пробелами справа до длины 50
Функция СформироватьИмяПользователяВСправочнике(Имя) Экспорт
	
	ИмяПользователя = Имя;
	Для Счетчик = СтрДлина(ИмяПользователя) + 1 По 50 Цикл
		ИмяПользователя = ИмяПользователя + " ";	
	КонецЦикла;
	
	ИмяПользователя = Лев(ИмяПользователя, 50);
	
	Возврат ИмяПользователя;
	
КонецФункции

// Процедура синхронизирует справочник пользователей с пользователями БД
Процедура СинхронизироватьПользователейИПользователейБД() Экспорт
	
	// при синхронизации списков пользователей и пользователей БД приоритетом
	// пользуются пользователи БД
	// если нет пользователя БД, то такой элемент списка пользователей помечаем на удаление
	// если пользователь БД есть а всписке такоео элемента нет, то добавляем его, а если он помечен на удаение, то снимаем пометку
	
	// имена пользователей БД могут быть заданы с незначащими символами
	// надо все незначимые символы из имен пользователей БД убрать
	МассивПользователейБД = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательБД Из МассивПользователейБД Цикл
		
		ИмяПользователяБД = СокрЛП(ПользовательБД.Имя);	
		Если ИмяПользователяБД <> ПользовательБД.Имя Тогда
			
			СтароеИмяПользователяБД = ПользовательБД.Имя;
			// полное имя тоже изменим если оно совпадает с имененм самого пользователя
			Если ПользовательБД.ПолноеИмя = ПользовательБД.Имя Тогда
				ПользовательБД.ПолноеИмя = ИмяПользователяБД;	
			КонецЕсли;
			ПользовательБД.Имя = ИмяПользователяБД;
			
			Попытка
				ПользовательБД.Записать();
			Исключение
				// не смогли пользователя еще одного записать, значит есть очень похожие имена
				Сообщить("В списке пользователей базы данных присутсвуют пользователи с именами """ + 
					СтароеИмяПользователяБД + """ и """ + ИмяПользователяБД + """", СтатусСообщения.Важное);
					
				Сообщить("Этим пользователям будет сопоставлен единственный элемент справочника ""Пользователи"" с именем  """ + ИмяПользователяБД + """", СтатусСообщения.Важное);	
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЦикла;
	
	// 1 Пробегаем по справочнику пользователей и каких пользователей в БД
	// не нашли - тех помечаем на удаление
	
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ
	                |	Пользователи.*
	                |ИЗ
	                |	Справочник.Пользователи КАК Пользователи
					|
					| ГДЕ Пользователи.ЭтоГруппа = Ложь 
					|	И Пользователи.ПометкаУдаления = Ложь";
	
	ТаблицаПользователей = Запрос.Выполнить().Выгрузить();
	Для Каждого ПользовательСправочника Из ТаблицаПользователей Цикл

		// Для пользователя с пустым именем не надо пользователя в БД создавать
		ИмяПользователя = СокрЛП(ПользовательСправочника.Код);
		Если ИмяПользователя = "" ИЛИ ИмяПользователя = "НеАвторизован" Тогда           
			Продолжить;
		КонецЕсли;
			
		// ищем пользователя БД по имени
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователя);
		Если ПользовательИБ = Неопределено Тогда
			// такого пользователя не нашли в пользователях БД - помечаем его на удаление
			
			ПользовательСсылка = Справочники.Пользователи.НайтиПоКоду(ПользовательСправочника.Код);
			// такого быть не может - должны найти всегда
			Если ОбщегоНазначения.ЗначениеНеЗаполнено(ПользовательСсылка) Тогда
				Продолжить;
			КонецЕсли;
			
			ПользовательОбъект = ПользовательСсылка.ПолучитьОбъект();
			Попытка
				// обходим что бы можно было установить пометку на удаление
				ПользовательОбъект.ОбменДанными.Загрузка = Истина;
				ПользовательОбъект.УстановитьПометкуУдаления(Истина, Ложь);
				#Если Клиент Тогда
				Сообщить("Пользователь """ + СокрЛП(ПользовательОбъект.КОД) + """ помечен на удаление в справочнике пользователей.");
				#КонецЕсли

			Исключение
				
				#Если Клиент Тогда
				Сообщить("Ошибка при пометке на удаления пользователя """ + СокрЛП(ПользовательОбъект.КОД) + """. " + ОписаниеОшибки());
				#КонецЕсли
 			
			КонецПопытки;
			
		КонецЕсли;
	
	КонецЦикла;
	
	// 2 Пробегаем по пользователеям БД и тех кого не нашли в справочнике добавляем
	Для Каждого ПользовательБД Из МассивПользователейБД Цикл
		
		ИмяПользователяВСправочнике = СформироватьИмяПользователяВСправочнике(ПользовательБД.Имя);
		ПользовательСправочника = Справочники.Пользователи.НайтиПоКоду(ИмяПользователяВСправочнике);
		// пользователя в справочнике нашли
		Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(ПользовательСправочника) Тогда
			
			ПользовательОбъект = ПользовательСправочника.ПолучитьОбъект();
			// нельзя что бы имя пользователя БД совпадало с именем группы
			Если ПользовательОбъект.ЭтоГруппа Тогда
				
				#Если Клиент Тогда
				Сообщить("Имя пользователя БД """ + СокрЛП(ПользовательОбъект.КОД) + """ совпадает с именем группы в справочнике пользователей!", СтатусСообщения.Важное);
				#КонецЕсли

				Продолжить;
			КонецЕсли;
			
			Если НЕ ПользовательОбъект.ПометкаУдаления Тогда
				Продолжить;
			КонецЕсли;
				
			Попытка
				// обходим что бы можно было установить пометку на удаление
				ПользовательОбъект.ОбменДанными.Загрузка = Истина;
				ПользовательОбъект.УстановитьПометкуУдаления(Ложь, Ложь);
				ПользовательОбъект.мПользовательБД = ПользовательБД;
		        ПользовательОбъект.Код          = ИмяПользователяВСправочнике;
				ПользовательОбъект.Наименование = ПользовательБД.ПолноеИмя;
					
				ПользовательОбъект.Записать();
				#Если Клиент Тогда
				Сообщить("У пользователя """ + СокрЛП(ПользовательОбъект.КОД) + """ снята пометка на удаление в справочнике пользователей.");
				#КонецЕсли

			Исключение
					
				#Если Клиент Тогда
				Сообщить("Ошибка при снятии пометки на удаления у пользователя """ + СокрЛП(ПользовательОбъект.КОД) + """. " + ОписаниеОшибки());
				#КонецЕсли
	 			
			КонецПопытки;
			
		Иначе
			// пользователя в справочнике не нашли
			ОбъектПользователь = Справочники.Пользователи.СоздатьЭлемент();
			//ОбъектПользователь.мПользовательБД = ПользовательБД;      //отсутствует такое свойство да и функция не используется
	        ОбъектПользователь.Код          = ИмяПользователяВСправочнике;
			ОбъектПользователь.Наименование = ПользовательБД.ПолноеИмя;

			Попытка
				ОбъектПользователь.Записать();
				
				#Если Клиент Тогда
				Сообщить("Пользователь """ + СокрЛП(ПользовательБД.Имя) + """ зарегистрирован в справочнике пользователей.");
				#КонецЕсли
			Исключение
				ОбщегоНазначения.СообщитьОбОшибке("Ошибка при добавлении пользователя """ + СокрЛП(ПользовательБД.Имя) + """ в справочник.");
		    КонецПопытки;

		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Процедура копирует пользователя БД с определенным именем и создает нового с такими же настройками
Функция СкопироватьПользователяБД(ИмяПользователяБД) Экспорт
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователяБД);
	Если ПользовательИБ = Неопределено Тогда
		ПолноеИмяПользователяБД = ИмяПользователяБД;
	Иначе
		ПолноеИмяПользователяБД = ПользовательИБ.ПолноеИмя;
	КонецЕсли;
	
	НовыйПользовательИБ = ДобавитьНовогоПользователяБД(ИмяПользователяБД, ПользовательИБ.ПолноеИмя, Ложь, Ложь);
	
	Если ПользовательИБ <> Неопределено Тогда
		// Если есть от кого копировать настройки - копируем
		НовыйПользовательИБ.ПользовательОС = ПользовательИБ.ПользовательОС;
		НовыйПользовательИБ.Пароль = "";
		НовыйПользовательИБ.АутентификацияСтандартная = ПользовательИБ.АутентификацияСтандартная;
		НовыйПользовательИБ.ПоказыватьВСпискеВыбора = ПользовательИБ.ПоказыватьВСпискеВыбора;
		НовыйПользовательИБ.АутентификацияОС = ПользовательИБ.АутентификацияОС;
		НовыйПользовательИБ.Язык = ПользовательИБ.Язык;
		НовыйПользовательИБ.ОсновнойИнтерфейс = ПользовательИБ.ОсновнойИнтерфейс;
		
		// Роли сохраняем
		Для Каждого ДоступныеРолиПользователяИБ Из ПользовательИБ.Роли Цикл
			НовыйПользовательИБ.Роли.Добавить(ДоступныеРолиПользователяИБ);
		КонецЦикла; 
	
	КонецЕсли;
  	
	Возврат  НовыйПользовательИБ;
	
КонецФункции

#Если Клиент Тогда

//Функция редактирует или создает нового пользователя БД
//Процедура редактирует пользователя БД
Функция РедактироватьИлиСоздатьПользователяБД(ОбъектПользователя, ТекущийПользовательБД, Знач Модифицированность = Ложь,
	Знач ПользовательДляКопированияНастроек = Неопределено) Экспорт
	
	СозданНовыйЭлемент = Ложь;
	
	Если ТекущийПользовательБД = Неопределено Тогда
		
		Если ОбъектПользователя = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
		
		ИмяПользователя = СокрЛП(ОбъектПользователя.Код);
		
		ОтветПользователя = Вопрос("Пользователь БД с именем """ + ИмяПользователя + """ не найден. Создать нового пользователя БД?", РежимДиалогаВопрос.ДаНет);
		Если ОтветПользователя <> КодВозвратаДиалога.Да Тогда
			Возврат Ложь;
		КонецЕсли;
		
		// создаем нового пользователя БД
		ТекущийПользовательБД = ПользователиИнформационнойБазы.СоздатьПользователя();
		ТекущийПользовательБД.Имя = ИмяПользователя;
		ТекущийПользовательБД.ПолноеИмя = СокрЛП(ОбъектПользователя.Наименование);
		
		СозданНовыйЭлемент = Истина;		
		
	КонецЕсли;
	
	// надо показать форму редактирования настроек пользователя БД
	ФормаРедактированияПользователяБД = ПолучитьОбщуюФорму("ФормаПользователяБД");
	ФормаРедактированияПользователяБД.ПользовательБД = ТекущийПользовательБД;
	ФормаРедактированияПользователяБД.ПользовательДляКопированияНастроек = ПользовательДляКопированияНастроек;
	ФормаРедактированияПользователяБД.Модифицированность = Модифицированность ИЛИ СозданНовыйЭлемент;
	ФормаРедактированияПользователяБД.Пользователь = ОбъектПользователя;
	
	РезультатОткрытия = ФормаРедактированияПользователяБД.ОткрытьМодально();
	
	Возврат РезультатОткрытия;
	
КонецФункции

#КонецЕсли
