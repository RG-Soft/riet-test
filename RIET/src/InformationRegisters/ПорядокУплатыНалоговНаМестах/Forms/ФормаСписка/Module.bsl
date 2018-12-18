
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиУчетаФормаСписка.ПриСозданииНаСервере(ЭтотОбъект, Отказ, СтандартнаяОбработка);
	
	Если Параметры.Свойство("Налог")
		И ЗначениеЗаполнено(Параметры.Налог) Тогда
			
		ВыборНалогаДоступен = Ложь;
		
		ЭтаФорма.АвтоЗаголовок = Ложь;
		Код = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Параметры.Налог, "Код");
		Если Код = "НалогНаИмущество" Тогда
			ЭтаФорма.Заголовок = НСтр("ru='Налог на имущество: порядок уплаты'");
		ИначеЕсли Код = "ТранспортныйНалог" Тогда
			ЭтаФорма.Заголовок = НСтр("ru='Транспортный налог: порядок уплаты'");
		ИначеЕсли Код = "ЗемельныйНалог" Тогда
			ЭтаФорма.Заголовок = НСтр("ru='Земельный налог: порядок уплаты'");
		КонецЕсли;
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список,
			"Налог",
			Параметры.Налог,
			ВидСравненияКомпоновкиДанных.Равно,
			,
			Истина,
			РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный);
		
	Иначе
			
		ВыборНалогаДоступен = Истина;
		
	КонецЕсли;
	
	УстановитьУсловноеОформление();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	НастройкиУчетаФормаСпискаКлиент.ОбработкаОповещения(ЭтотОбъект, ИмяСобытия, Параметр, Источник);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВыборНалогаДоступен", ВыборНалогаДоступен);
	ПараметрыФормы.Вставить("Ключ", ВыбраннаяСтрока);
	
	ОткрытьФорму("РегистрСведений.ПорядокУплатыНалоговНаМестах.ФормаЗаписи", ПараметрыФормы, ЭтаФорма); 
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	
	// Налог
	
	ЭлементУО = УсловноеОформление.Элементы.Добавить();
	
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "Налог");
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"ВыборНалогаДоступен", ВидСравненияКомпоновкиДанных.Равно, Ложь);
	
	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
КонецПроцедуры

&НаСервере
Процедура СписокПередЗагрузкойПользовательскихНастроекНаСервере(Элемент, Настройки)
	
	НастройкиУчетаФормаСписка.СписокПередЗагрузкойПользовательскихНастроекНаСервере(ЭтотОбъект, Элемент, Настройки);
	
КонецПроцедуры
