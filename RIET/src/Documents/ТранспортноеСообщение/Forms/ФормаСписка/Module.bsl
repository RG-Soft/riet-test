
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Параметры.РежимВыбора Тогда
		Элементы.СписокКнопкаВыбрать.Видимость = Истина;
		Элементы.СписокКнопкаВыбрать.КнопкаПоУмолчанию = Истина;
	Иначе
		Элементы.СписокКнопкаВыбрать.Видимость = Ложь;
	КонецЕсли;
	
	МассивПолученныхСообщений = Новый Массив;
	Оповестить("Заполнение списка полученных сообщений", МассивПолученныхСообщений);
	Если МассивПолученныхСообщений.Количество() > 0 Тогда 
		ПолученныеТранспортныеСообщения.ЗагрузитьЗначения(МассивПолученныхСообщений);
		Список.Параметры.УстановитьЗначениеПараметра("ПолученныеТранспортныеСообщения", МассивПолученныхСообщений);
	Иначе
		Список.Параметры.УстановитьЗначениеПараметра("ПолученныеТранспортныеСообщения", Неопределено);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрТекущаяСтрока) Тогда 
		Элементы.Список.ТекущаяСтрока = ПараметрТекущаяСтрока;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Параметры.РежимВыбора Тогда
		СтандартнаяОбработка = Ложь;
		ОповеститьОВыборе(ВыбраннаяСтрока);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура КомандаСписокВыбрать(Команда)
	
	Если Параметры.РежимВыбора Тогда
		ОповеститьОВыборе(Элементы.Список.ТекущаяСтрока);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Чтение сообщения" И ТипЗнч(Параметр) = Тип("Структура") Тогда
		
		Если Параметр.Свойство("Сообщение") Тогда 
			ЭлементСписка = ПолученныеТранспортныеСообщения.НайтиПоЗначению(Параметр.Сообщение);
			Если ЭлементСписка <> Неопределено Тогда 
				ПолученныеТранспортныеСообщения.Удалить(ЭлементСписка);
				
			КонецЕсли;
		КонецЕсли;
		
		Если ПолученныеТранспортныеСообщения.Количество() > 0 Тогда 
			ЗначениеПараметраПолученныеТС = ПолученныеТранспортныеСообщения.ВыгрузитьЗначения();
		Иначе
			Возврат; //ЗначениеПараметраПолученныеТС = Неопределено;
		КонецЕсли;
		
		Список.Параметры.УстановитьЗначениеПараметра("ПолученныеТранспортныеСообщения", ЗначениеПараметраПолученныеТС);
		
	ИначеЕсли ИмяСобытия = "Заполнение списка полученных сообщений" И ТипЗнч(Параметр) = Тип("Массив") Тогда
		
		Если Параметр.Количество() > 0 Тогда 
			// оповещение отправлено формой с НЕ пустым списком (был выполнен обмен)
			Для Каждого ЭлементПараметра Из Параметр Цикл
				ЭлементСписка = ПолученныеТранспортныеСообщения.НайтиПоЗначению(ЭлементПараметра);
				Если ЭлементСписка = Неопределено Тогда 
					ПолученныеТранспортныеСообщения.Добавить(ЭлементПараметра);
				КонецЕсли;
			КонецЦикла;
			Список.Параметры.УстановитьЗначениеПараметра("ПолученныеТранспортныеСообщения", ПолученныеТранспортныеСообщения.ВыгрузитьЗначения());
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ТекущаяСтрока") Тогда
		Если ТипЗнч(Параметры.ТекущаяСтрока) = Тип("ДокументСсылка.ТранспортноеСообщение") Тогда
			ПараметрТекущаяСтрока = Параметры.ТекущаяСтрока;
		КонецЕсли;
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоПлатформа83БезРежимаСовместимости() Тогда
		
		Если Параметры.Отбор.Свойство("ЦиклОбмена") Тогда
			ЦиклОбмена = Параметры.Отбор.ЦиклОбмена;
			
			// Установка значения отбора в компоновщике настроек.
			ЭлементОтбораДанных = Список.КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));	
			ЭлементОтбораДанных.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ЦиклОбмена");
			ЭлементОтбораДанных.ПравоеЗначение = ЦиклОбмена;
			ЭлементОтбораДанных.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
			ЭлементОтбораДанных.Использование = Истина;
			
			// Удаление отбора из параметров.
			Параметры.Отбор.Удалить("ЦиклОбмена"); 
		КонецЕсли;
		
		Если Параметры.Отбор.Свойство("Тип") Тогда
			ТипСообщения = Параметры.Отбор.Тип;
			
			// Установка значения отбора в компоновщике настроек.
			ЭлементОтбораДанных = Список.КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));	
			ЭлементОтбораДанных.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Тип");
			ЭлементОтбораДанных.ПравоеЗначение = ТипСообщения;
			ВидСравненияОтбора = ВидСравненияКомпоновкиДанных.Равно;
			Если ТипЗнч(ТипСообщения) = Тип("СписокЗначений") И ТипСообщения.Количество() > 1 Тогда
				ВидСравненияОтбора = ВидСравненияКомпоновкиДанных.ВСписке;
			КонецЕсли;
				
			ЭлементОтбораДанных.ВидСравнения = ВидСравненияОтбора;

			ЭлементОтбораДанных.Использование = Истина;
			
			// Удаление отбора из параметров.
			Параметры.Отбор.Удалить("Тип"); 
		КонецЕсли;
		
		Список.КомпоновщикНастроек.Настройки.Отбор.ИдентификаторПользовательскойНастройки = Строка(Новый УникальныйИдентификатор);
		
	КонецЕсли;
	
КонецПроцедуры
