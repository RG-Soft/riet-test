#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
Процедура ЗаполнитьЦеликомПредопределенныеВидыОтправляемыхДокументов() Экспорт
	
	ЗаполнитьПредопределенныеВидыОтправляемыхДокументов(Истина);
	
КонецПроцедуры 

Процедура ОбновитьНаименованияПредопределенныхЭлементов() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВидыОтправляемыхДокументов.Ссылка,
	|	ВидыОтправляемыхДокументов.Наименование,
	|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|ИЗ
	|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
	|ГДЕ
	|	ВидыОтправляемыхДокументов.Предопределенный = ИСТИНА
	|	И ВидыОтправляемыхДокументов.ЭтоГруппа = ЛОЖЬ";	
	
	Результат = Запрос.Выполнить();
	
	ВыборкаРезультата = Результат.Выбрать();
	
	СоответствиеСвойств = ПолучитьСоответствиеСвойствВидовОтправляемыхДокументов();
	
	ВыборкаРезультата = Результат.Выбрать();
	
	//заполняем свойства, перебирая выборку результата запроса
	Пока ВыборкаРезультата.Следующий() Цикл
		СпрСсылка = ВыборкаРезультата.Ссылка;
		СпрИмя = ВыборкаРезультата.ИмяПредопределенныхДанных;
		ЭталонныеСвойства = СоответствиеСвойств[СпрИмя];
		
		Если ЭталонныеСвойства = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ЭталонНаименование 	= ЭталонныеСвойства.Наименование;
		
		Если ВыборкаРезультата.Наименование <> ЭталонНаименование Тогда
			
			СпрОбъект = СпрСсылка.ПолучитьОбъект();
			
			СпрОбъект.Наименование = ЭталонНаименование;
			
			СпрОбъект.ОбменДанными.Загрузка = Истина;
			
			СпрОбъект.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры 

// Получает список видов отправляемых документов по шаблону, представленному
// в макете ОписаниеВидовОтправляемыхДокументов объекта Справочник.ВидыОтправляемыхДокументов
//
Функция ПолучитьСоответствиеСвойствВидовОтправляемыхДокументов(МассивВыборочныхИмен = Неопределено) 

	ВыборочноеЗаполнение = (МассивВыборочныхИмен <> Неопределено);
	
	РезультатСоответствие = Новый Соответствие;
	
	// Получим макет со списком документов.
	МакетСписокДокументов = Справочники.ВидыОтправляемыхДокументов.ПолучитьМакет("ОписаниеВидовОтправляемыхДокументов");

	Для Инд = 0 По МакетСписокДокументов.Области.Количество() - 1 Цикл

		ТекОбласть = МакетСписокДокументов.Области[Инд];

		ИмяГруппы 			= СокрЛП(МакетСписокДокументов.Область(ТекОбласть.Верх, 1).Текст);
		НаименованиеГруппы 	= СокрЛП(МакетСписокДокументов.Область(ТекОбласть.Верх, 2).Текст);
		ОписаниеГруппы		= СокрЛП(МакетСписокДокументов.Область(ТекОбласть.Верх, 3).Текст);
		
		Если Не ПустаяСтрока(ИмяГруппы) Тогда

			Для Ном = ТекОбласть.Верх По ТекОбласть.Низ Цикл
				
				// перебираем элементы второго уровня
				ИмяЭлемента = СокрЛП(МакетСписокДокументов.Область(Ном, 1).Текст);
				
				Если ВыборочноеЗаполнение Тогда
					Если МассивВыборочныхИмен.Найти(ИмяЭлемента) = Неопределено Тогда
						Продолжить;
					КонецЕсли;
				КонецЕсли;
				
				СтруктураСвойствЭлемента = Новый Структура();
				СтруктураСвойствЭлемента.Вставить("Наименование", 	СокрЛП(МакетСписокДокументов.Область(Ном, 2).Текст));
				СтруктураСвойствЭлемента.Вставить("Описание", 		СокрЛП(МакетСписокДокументов.Область(Ном, 3).Текст));
				СтруктураСвойствЭлемента.Вставить("Источник", 		СокрЛП(МакетСписокДокументов.Область(Ном, 4).Текст));
				СтруктураСвойствЭлемента.Вставить("ТипПолучателя", 	СокрЛП(МакетСписокДокументов.Область(Ном, 5).Текст));
				СтруктураСвойствЭлемента.Вставить("ТипДокумента", 	СокрЛП(МакетСписокДокументов.Область(Ном, 6).Текст));
				
				РезультатСоответствие.Вставить(ИмяЭлемента, СтруктураСвойствЭлемента);
			КонецЦикла;

		Иначе
			// для элемента корневого (0-уровня)
			Для Ном = ТекОбласть.Верх По ТекОбласть.Низ Цикл
				
				// перебираем элементы второго уровня
				ИмяЭлемента = СокрЛП(МакетСписокДокументов.Область(Ном, 1).Текст);
				
				Если ВыборочноеЗаполнение Тогда
					Если МассивВыборочныхИмен.Найти(ИмяЭлемента) = Неопределено Тогда
						Продолжить;
					КонецЕсли;
				КонецЕсли;

				СтруктураСвойствЭлемента = Новый Структура();
				СтруктураСвойствЭлемента.Вставить("Наименование", 	СокрЛП(МакетСписокДокументов.Область(Ном, 2).Текст));
				СтруктураСвойствЭлемента.Вставить("Описание", 		СокрЛП(МакетСписокДокументов.Область(Ном, 3).Текст));
				СтруктураСвойствЭлемента.Вставить("Источник", 		СокрЛП(МакетСписокДокументов.Область(Ном, 4).Текст));
				СтруктураСвойствЭлемента.Вставить("ТипПолучателя", 	СокрЛП(МакетСписокДокументов.Область(Ном, 5).Текст));
				СтруктураСвойствЭлемента.Вставить("ТипДокумента", 	СокрЛП(МакетСписокДокументов.Область(Ном, 6).Текст));
				
				РезультатСоответствие.Вставить(ИмяЭлемента, СтруктураСвойствЭлемента);

			КонецЦикла;

		КонецЕсли;

	КонецЦикла;
	
	Возврат РезультатСоответствие;

КонецФункции

// Обработчик обновления БРО.
//
// Вызывается при каждом обновлении ИБ.
// Заполняет реквизиты предопределенных элементов справочника "ВидыОтправляемыхДокументов".
Процедура ЗаполнитьПредопределенныеВидыОтправляемыхДокументов(СправочникЦеликом = Ложь) Экспорт
	
	Если СправочникЦеликом Тогда
		
		// полное заполнение при интерактивном выборе восстановления
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВидыОтправляемыхДокументов.Ссылка,
		|	ВидыОтправляемыхДокументов.Наименование,
		|	ВидыОтправляемыхДокументов.Описание,
		|	ВидыОтправляемыхДокументов.Источник,
		|	ВидыОтправляемыхДокументов.ТипПолучателя,
		|	ВидыОтправляемыхДокументов.ТипДокумента,
		|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
		|ИЗ
		|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
		|ГДЕ
		|	ВидыОтправляемыхДокументов.Предопределенный = ИСТИНА
		|	И ВидыОтправляемыхДокументов.ЭтоГруппа = ЛОЖЬ";	
		
		Результат = Запрос.Выполнить();
		
		ВыборкаРезультата = Результат.Выбрать();
		
		СоответствиеСвойств = ПолучитьСоответствиеСвойствВидовОтправляемыхДокументов();
		
	Иначе
		
		ОбработатьПредопределенныеВидыОправляемыхДокументов();
		
		// частичное заполнение при обновлении ИБ
		УдалитьДублиПредопределенныеВидыОтправляемыхДокументов();
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВидыОтправляемыхДокументов.Ссылка,
		|	ВидыОтправляемыхДокументов.Наименование,
		|	ВидыОтправляемыхДокументов.Описание,
		|	ВидыОтправляемыхДокументов.Источник,
		|	ВидыОтправляемыхДокументов.ТипПолучателя,
		|	ВидыОтправляемыхДокументов.ТипДокумента,
		|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
		|ИЗ
		|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
		|ГДЕ
		|	ВидыОтправляемыхДокументов.Предопределенный = ИСТИНА
		|	И ВидыОтправляемыхДокументов.ЭтоГруппа = ЛОЖЬ
		|	И (ВидыОтправляемыхДокументов.Источник = """"
		|			ИЛИ ВидыОтправляемыхДокументов.ТипПолучателя = ЗНАЧЕНИЕ(Перечисление.ТипыКонтролирующихОрганов.ПустаяСсылка)
		|			ИЛИ ВидыОтправляемыхДокументов.ТипДокумента = ЗНАЧЕНИЕ(Перечисление.ТипыОтправляемыхДокументов.ПустаяСсылка))";	
		
		Результат = Запрос.Выполнить();
		
		Если Результат.Пустой() Тогда
			//свойства всех предопределенных элементов заполнены
			Возврат;	
		КонецЕсли;
		
		ВыборкаРезультата = Результат.Выбрать();
		
		МассивНезаполненныхЭлементов = Новый Массив;
		
		Пока ВыборкаРезультата.Следующий() Цикл
			ИмяЭлемента = ВыборкаРезультата.ИмяПредопределенныхДанных;
			МассивНезаполненныхЭлементов.Добавить(ИмяЭлемента);	
		КонецЦикла;
		
		СоответствиеСвойств = ПолучитьСоответствиеСвойствВидовОтправляемыхДокументов(МассивНезаполненныхЭлементов);
		
	КонецЕсли;
	
	ВыборкаРезультата = Результат.Выбрать();
	
	//заполняем свойства, перебирая выборку результата запроса
	Пока ВыборкаРезультата.Следующий() Цикл
		СпрСсылка = ВыборкаРезультата.Ссылка;
		СпрИмя = ВыборкаРезультата.ИмяПредопределенныхДанных;
		ЭталонныеСвойства = СоответствиеСвойств[СпрИмя];
		
		Если ЭталонныеСвойства = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ЭталонНаименование 	= ЭталонныеСвойства.Наименование;
		ЭталонОписание 		= ЭталонныеСвойства.Описание;
		ЭталонИсточник 		= ЭталонныеСвойства.Источник;
		ЭталонТипПолучателя = Перечисления.ТипыКонтролирующихОрганов[ЭталонныеСвойства.ТипПолучателя];
		ЭталонТипДокумента 	= Перечисления.ТипыОтправляемыхДокументов[ЭталонныеСвойства.ТипДокумента];
		
		Если ВыборкаРезультата.Наименование <> ЭталонНаименование
			ИЛИ ВыборкаРезультата.Описание <> ЭталонОписание
			ИЛИ ВыборкаРезультата.Источник <> ЭталонИсточник
			ИЛИ ВыборкаРезультата.ТипПолучателя <> ЭталонТипПолучателя
			ИЛИ ВыборкаРезультата.ТипДокумента <> ЭталонТипДокумента Тогда
			
			СпрОбъект = СпрСсылка.ПолучитьОбъект();
			
			СпрОбъект.Наименование = ЭталонНаименование;
			СпрОбъект.Описание = ЭталонОписание;
			СпрОбъект.Источник = ЭталонИсточник;
			СпрОбъект.ТипПолучателя = ЭталонТипПолучателя;
			СпрОбъект.ТипДокумента = ЭталонТипДокумента;
			
			СпрОбъект.ОбменДанными.Загрузка = Истина;
			
			СпрОбъект.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры // ЗаполнитьПредопределенныеВидыОтправляемыхДокументов()

// Вспомогательная функция для УдалитьДублиПредопределенныеВидыОтправляемыхДокументов 
Функция НастроенОбменРИБ()
	
	//Если ПолучитьФункциональнуюОпцию("ИспользоватьСинхронизациюДанных") = Истина Тогда
	//	Для каждого ПланОбмена Из Метаданные.ПланыОбмена Цикл
	//		Если ПланОбмена.РаспределеннаяИнформационнаяБаза Тогда
	//			МенеджерПланаОбмена = ПланыОбмена[ПланОбмена.Имя];
	//			ВыборкаУзлов = МенеджерПланаОбмена.Выбрать();
	//			Пока ВыборкаУзлов.Следующий() Цикл
	//				Если ВыборкаУзлов.Ссылка <> МенеджерПланаОбмена.ЭтотУзел() Тогда
	//					Возврат Истина;
	//				КонецЕсли;    
	//			КонецЦикла;
	//		КонецЕсли;
	//	КонецЦикла;
	//КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции 

// Удаляет дубли предопределенных элементов справочника "ВидыОтправляемыхДокументов".
Процедура УдалитьДублиПредопределенныеВидыОтправляемыхДокументов()
	
	Если НЕ НастроенОбменРИБ() Тогда
		Возврат;
	КонецЕсли;

	//удаление элементов с разными ссылками и одинаковым именем предопределенных данных
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВидыОтправляемыхДокументов.Ссылка) КАК КолвоСсылок,
	|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|ПОМЕСТИТЬ КолвоРазныхСсылокПоИмениПредопределенного
	|ИЗ
	|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
	|ГДЕ
	|	ВидыОтправляемыхДокументов.Предопределенный = ИСТИНА
	|
	|СГРУППИРОВАТЬ ПО
	|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КолвоРазныхСсылокПоИмениПредопределенного.ИмяПредопределенныхДанных
	|ПОМЕСТИТЬ ЗадублированныеИменаПредопределенных
	|ИЗ
	|	КолвоРазныхСсылокПоИмениПредопределенного КАК КолвоРазныхСсылокПоИмениПредопределенного
	|ГДЕ
	|	КолвоРазныхСсылокПоИмениПредопределенного.КолвоСсылок > 1
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадублированныеИменаПредопределенных.ИмяПредопределенныхДанных,
	|	ВидыОтправляемыхДокументов.Ссылка КАК Ссылка
	|ИЗ
	|	ЗадублированныеИменаПредопределенных КАК ЗадублированныеИменаПредопределенных
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
	|		ПО ЗадублированныеИменаПредопределенных.ИмяПредопределенныхДанных = ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка";	
	
	Результат = Запрос.Выполнить();
	
	ВыборкаРезультата = Результат.Выбрать();
	
	МассивИмен = Новый Массив;
	
	Пока ВыборкаРезультата.Следующий() Цикл
		ИмяПредопределенныхДанных = ВыборкаРезультата.ИмяПредопределенныхДанных;
		
		Если МассивИмен.Найти(ИмяПредопределенныхДанных) = Неопределено Тогда
			//ссылки упорядочены, первую не удаляем
			МассивИмен.Добавить(ИмяПредопределенныхДанных);
		    Продолжить;
		КонецЕсли;
		
		СпрСсылка = ВыборкаРезультата.Ссылка;
		СпрОбъект = СпрСсылка.ПолучитьОбъект();
		СпрОбъект.ИмяПредопределенныхДанных = "";
		СпрОбъект.ПометкаУдаления = Истина;
		СпрОбъект.ОбменДанными.Загрузка = Истина;
		
		СпрОбъект.Записать();
	КонецЦикла;
	
	//удаление элементов с одинаковыми ссылками и одинаковым именем предопределенных данных
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВидыОтправляемыхДокументов.Ссылка) КАК КолвоРазличных,
	|	КОЛИЧЕСТВО(ВидыОтправляемыхДокументов.Ссылка) КАК КолвоОбщее,
	|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|ПОМЕСТИТЬ КолвоСсылокПоИмениПредопределенного
	|ИЗ
	|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
	|ГДЕ
	|	ВидыОтправляемыхДокументов.Предопределенный = ИСТИНА
	|
	|СГРУППИРОВАТЬ ПО
	|	ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КолвоСсылокПоИмениПредопределенного.ИмяПредопределенныхДанных
	|ПОМЕСТИТЬ ИменаПредопределенных
	|ИЗ
	|	КолвоСсылокПоИмениПредопределенного КАК КолвоСсылокПоИмениПредопределенного
	|ГДЕ
	|	КолвоСсылокПоИмениПредопределенного.КолвоРазличных = 1
	|	И КолвоСсылокПоИмениПредопределенного.КолвоОбщее > 1
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВидыОтправляемыхДокументов.Ссылка КАК Ссылка,
	|	ИменаПредопределенных.ИмяПредопределенныхДанных
	|ИЗ
	|	ИменаПредопределенных КАК ИменаПредопределенных
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
	|		ПО ИменаПредопределенных.ИмяПредопределенныхДанных = ВидыОтправляемыхДокументов.ИмяПредопределенныхДанных
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка";	
	
	Результат = Запрос.Выполнить();
	
	ВыборкаРезультата = Результат.Выбрать();
	
	МассивСсылок = Новый Массив;
	
	Пока ВыборкаРезультата.Следующий() Цикл
		СпрСсылка = ВыборкаРезультата.Ссылка;
		
		Если МассивСсылок.Найти(СпрСсылка) = Неопределено Тогда
			//ссылки одинаковые, первую не удаляем
			МассивСсылок.Добавить(СпрСсылка);
		    Продолжить;
		КонецЕсли;
		
		СпрОбъект = СпрСсылка.ПолучитьОбъект();
		СпрОбъект.ОбменДанными.Загрузка = Истина;
		СпрОбъект.Удалить();
	КонецЦикла;
	
КонецПроцедуры // УдалитьДублиПредопределенныеВидыОтправляемыхДокументов()

Процедура ОбработатьПредопределенныеВидыОправляемыхДокументов()
	
	Если ПланыОбмена.ГлавныйУзел() = Неопределено Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ВидыОтправляемыхДокументов.Ссылка
		|ИЗ
		|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
		|ГДЕ
		|	НЕ ВидыОтправляемыхДокументов.ПомеченВГлавномУзле
		|	И ВидыОтправляемыхДокументов.Предопределенный";
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Пока Выборка.Следующий() Цикл
			ВидОтправляемыхДокументовОбъект = Выборка.Ссылка.ПолучитьОбъект();
			ВидОтправляемыхДокументовОбъект.ПомеченВГлавномУзле = Истина;
			ВидОтправляемыхДокументовОбъект.ОбменДанными.Загрузка = Истина;
			ВидОтправляемыхДокументовОбъект.Записать();
		КонецЦикла;	
	Иначе
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ВидыОтправляемыхДокументов.Ссылка
		|ИЗ
		|	Справочник.ВидыОтправляемыхДокументов КАК ВидыОтправляемыхДокументов
		|ГДЕ
		|	НЕ ВидыОтправляемыхДокументов.ПомеченВГлавномУзле
		|	И ВидыОтправляемыхДокументов.Предопределенный";
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Пока Выборка.Следующий() Цикл
			ВидОтправляемыхДокументовОбъект = Выборка.Ссылка.ПолучитьОбъект();
			ВидОтправляемыхДокументовОбъект.ИмяПредопределенныхДанных = "";
			ВидОтправляемыхДокументовОбъект.ПометкаУдаления = Истина;
			ВидОтправляемыхДокументовОбъект.ОбменДанными.Загрузка = Истина;
			ВидОтправляемыхДокументовОбъект.ОбменДанными.Получатели.АвтоЗаполнение = Ложь;
			ВидОтправляемыхДокументовОбъект.Записать();
		КонецЦикла;		
	КонецЕсли;
	
КонецПроцедуры

#КонецЕсли