&НаКлиенте
Перем КонтекстЭДОКлиент;

&НаСервере
Перем КонтекстЭДОСервер;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	// инициализируем контекст ЭДО - модуль обработки
	ТекстСообщения = "";
	КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО(ТекстСообщения);
	Если КонтекстЭДОСервер = Неопределено Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	ЭтоНовый = Параметры.Ключ.Пустая();
	Если ЭтоНовый Тогда
		ТекстПредупреждения = ВернутьСтр("ru = 'Копирование описей входящих документов запрещено!'");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	ПрорисоватьПанелиСтатусаИПриема();
	ЗаполнитьОтветы();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОтветы()
	
	Если КонтекстЭДОСервер = Неопределено Тогда 
		// инициализируем контекст ЭДО - модуль обработки
		ТекстСообщения = "";
		КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО(ТекстСообщения);
		Если КонтекстЭДОСервер = Неопределено Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			Возврат;
		КонецЕсли;
	КонецЕсли;

	// собираем ссылки на документы
	МассивДокументы = Новый Массив;
	Для Каждого ДанныеСтроки Из Объект.ВходящиеДокументы Цикл
		МассивДокументы.Добавить(ДанныеСтроки.СсылкаНаОбъект);
	КонецЦикла;
	
	// получаем количество ответов на требования
	КоличествоОтветов =  КонтекстЭДОСервер.ПолучитьКоличествоОтветовНаТребования(МассивДокументы);
	
	// прорисовываем ответы
	Для Каждого ДанныеСтроки Из Объект.ВходящиеДокументы Цикл
		КолвоОтветов = КоличествоОтветов[ДанныеСтроки.СсылкаНаОбъект];
		Если КолвоОтветов > 0 Тогда
			ДанныеСтроки.Ответ = КонтекстЭДОСервер.ПолучитьТекстКоличествоОтветов(КолвоОтветов);
		Иначе
			Если ДанныеСтроки.СсылкаНаОбъект.ВидДокумента = Перечисления.ВидыНалоговыхДокументов.ТребованиеОПредставленииДокументов Тогда
				//этот документ реализации является требованием
				ДанныеСтроки.Ответ = "Создать";
			Иначе
				//этот документ реализации не является требованием
				ДанныеСтроки.Ответ = "<не требуется>";
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ПрорисоватьПанелиСтатусаИПриема()
	
	// Прорисовываем видимость панели
	Если КонтекстЭДОСервер = Неопределено Тогда 
		//// инициализируем контекст ЭДО - модуль обработки
		ТекстСообщения = "";
		КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО(ТекстСообщения);
		Если КонтекстЭДОСервер = Неопределено Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			Возврат;
		КонецЕсли;
	КонецЕсли;

	// получаем список сообщений
	ПоследнийЦиклОбмена = КонтекстЭДОСервер.ПолучитьПоследнийЦиклОбмена(Объект.Ссылка);
	СообщенияЦикла = КонтекстЭДОСервер.ПолучитьСообщенияЦиклаОбмена(ПоследнийЦиклОбмена);
	СтрРезультатПриемаДокументНП 	= СообщенияЦикла.НайтиСтроки(Новый Структура("Тип", Перечисления.ТипыТранспортныхСообщений.РезультатПриемаДокументНП));
	//прорисуем панель приема
	Если СтрРезультатПриемаДокументНП.Количество() > 0 
		ИЛИ КонтекстЭДОСервер.ПолучитьМассивТребованийПоОписиВходящихДокументов(Объект.Ссылка).Количество() = 0 
		ИЛИ НЕ ЗначениеЗаполнено(ПоследнийЦиклОбмена) Тогда
		Элементы.ГруппаПанельПриема.Видимость = Ложь;
	Иначе
        Элементы.ГруппаПанельПриема.Видимость = Истина;
	КонецЕсли;

	
КонецПроцедуры

&НаСервере
Функция ПолучитьРезультатПриемаНаСервере()

	Если КонтекстЭДОСервер = Неопределено Тогда 
		//// инициализируем контекст ЭДО - модуль обработки
		ТекстСообщения = "";
		КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО(ТекстСообщения);
		Если КонтекстЭДОСервер = Неопределено Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	// получаем список сообщений
	ПоследнийЦиклОбмена 		= КонтекстЭДОСервер.ПолучитьПоследнийЦиклОбмена(Объект.Ссылка);
	СообщениеОснование			= КонтекстЭДОСервер.ПолучитьСообщениеЦиклаОбмена(ПоследнийЦиклОбмена, Перечисления.ТипыТранспортныхСообщений.ДокументНО);
	СообщениеРезультатПриема 	= КонтекстЭДОСервер.ПолучитьСообщениеЦиклаОбмена(ПоследнийЦиклОбмена, Перечисления.ТипыТранспортныхСообщений.РезультатПриемаДокументНП, СообщениеОснование);
	Если СообщениеРезультатПриема = Документы.ТранспортноеСообщение.ПустаяСсылка() Тогда
		Возврат Неопределено;
	Иначе
		Возврат СообщениеРезультатПриема;
	КонецЕсли;

КонецФункции

&НаСервере
Функция ПолучитьДокументНОНаСервере()

	Если КонтекстЭДОСервер = Неопределено Тогда 
		//// инициализируем контекст ЭДО - модуль обработки
		ТекстСообщения = "";
		КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО(ТекстСообщения);
		Если КонтекстЭДОСервер = Неопределено Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	// получаем список сообщений
	ПоследнийЦиклОбмена 		= КонтекстЭДОСервер.ПолучитьПоследнийЦиклОбмена(Объект.Ссылка);
	СообщениеДокументНО			= КонтекстЭДОСервер.ПолучитьСообщениеЦиклаОбмена(ПоследнийЦиклОбмена, Перечисления.ТипыТранспортныхСообщений.ДокументНО);
	Если СообщениеДокументНО = Документы.ТранспортноеСообщение.ПустаяСсылка() Тогда
		Возврат Неопределено;
	Иначе
		Возврат СообщениеДокументНО;
	КонецЕсли;

КонецФункции

&НаКлиенте
Процедура КомандаПодтвердитьПрием(Команда)
	
	ОтправитьРезультатПриема(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтказатьВПриеме(Команда)
	
	ОтправитьРезультатПриема(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьРезультатПриема(ПоложительныйРезультат = Истина)
	
	РезультатПриема = ПолучитьРезультатПриемаНаСервере();
	Если РезультатПриема = Неопределено Тогда
		Если ПоложительныйРезультат Тогда
			ТекстВопроса = "Подтвердить прием описи документов, содержащей требование о представлении документов (информации)?" 
				+ Символы.ПС + "Подтверждение будет отправлено в налоговый орган." 
				+ Символы.ПС + "После отправки подтверждения приема следует сформировать ответ, содержащий затребованные документы.";
		Иначе
			ТекстВопроса = "Отказать в приеме описи документов, содержащей требование о представлении документов (информации)?" 
				+ Символы.ПС + "Отказ будет отправлен в налоговый орган.";
		КонецЕсли;
		
		ДополнительныеПараметры = Новый Структура;
		ДополнительныеПараметры.Вставить("ПоложительныйРезультат", ПоложительныйРезультат);
		ДополнительныеПараметры.Вставить("РезультатПриема", РезультатПриема);
		ОписаниеОповещения = Новый ОписаниеОповещения("ОтправитьРезультатПриемаЗавершение", ЭтотОбъект, ДополнительныеПараметры);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
		
	Иначе
		ПоказатьЗначение(, РезультатПриема);	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОтправитьРезультатПриемаЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	РезультатПриема = ДополнительныеПараметры.РезультатПриема;
	ПоложительныйРезультат = ДополнительныеПараметры.ПоложительныйРезультат;
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	ДокументНО = ПолучитьДокументНОНаСервере();
	//отправляем сообщение
	Если ДокументНО <> Неопределено Тогда
		РезультатПриема = КонтекстЭДОКлиент.СоздатьРезультатПриемаНаКлиентеСУчетомВопроса(ДокументНО, ПоложительныйРезультат, Истина);
		Если РезультатПриема <> Неопределено Тогда
			КонтекстЭДОКлиент.СформироватьПакетФНС(РезультатПриема);
			//отправляем сообщение
			КонтекстЭДОКлиент.ОтправитьТранспортноеСообщение(РезультатПриема);
			ПрорисоватьПанелиСтатусаИПриема()
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	// инициализируем контекст формы - контейнера клиентских методов
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриОткрытииЗавершение", ЭтотОбъект);
	ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытииЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент = Неопределено Тогда
		ОтключитьДоступностьЭУ();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьДоступностьЭУ()
	
	Элементы.ГруппаПанельПриема.Доступность = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ВходящиеДокументыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДокументРеализации = Элемент.ТекущиеДанные.СсылкаНаОбъект;
	
	Если Поле.Имя = "ВходящиеДокументыОтвет" Тогда
		Если Элемент.ТекущиеДанные.Ответ <> "<не требуется>" Тогда
			//этот документ реализации является требованием
			СоздатьПоказатьОтветНаТребование(ДокументРеализации);
		Иначе
			ПоказатьЗначение(, ДокументРеализации);	
		КонецЕсли;
	Иначе
		ПоказатьЗначение(, ДокументРеализации);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СоздатьПоказатьОтветНаТребование(Требование)
	
	МассивОписейИсходящихДокументов = ПолучитьМассивОписейИсходящихДокументовПоТребованию(Требование);
	
	Если МассивОписейИсходящихДокументов.Количество() = 0 Тогда
		
		КонтекстЭДОКлиент.СоздатьИсходящуюОписьПоОснованию(Требование);
		
	Иначе
		
		Если МассивОписейИсходящихДокументов.Количество() > 1 Тогда
			
			СписокОписейИсходящихДокументов = Новый СписокЗначений;
			СписокОписейИсходящихДокументов.ЗагрузитьЗначения(МассивОписейИсходящихДокументов);
			
			ПараметрыФормы = Новый Структура;
			ПараметрыФормы.Вставить("СписокОписей", СписокОписейИсходящихДокументов);
			ПараметрыФормы.Вставить("Требование", Требование);
			ОткрытьФорму("Справочник.ОписиИсходящихДокументовВНалоговыеОрганы.Форма.ФормаГрупповойОтправки", ПараметрыФормы, , Новый УникальныйИдентификатор);
			
		Иначе
			
			ПоказатьЗначение(, МассивОписейИсходящихДокументов[0]);
			
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьМассивОписейИсходящихДокументовПоТребованию(ОбъектСсылка)
	
	КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО();
	Возврат КонтекстЭДОСервер.ПолучитьМассивОписейИсходящихДокументовПоТребованию(ОбъектСсылка);	
	
КонецФункции

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_ОписиИсходящихДокументовВНалоговыеОрганы" И ТипЗнч(Параметр) = Тип("СправочникСсылка.ОписиИсходящихДокументовВНалоговыеОрганы") Тогда
		ЗаполнитьОтветы();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Оповестить("Запись_ОписиВходящихДокументовИзНалоговыхОрганов", ПараметрыЗаписи, Объект.Ссылка);
КонецПроцедуры
