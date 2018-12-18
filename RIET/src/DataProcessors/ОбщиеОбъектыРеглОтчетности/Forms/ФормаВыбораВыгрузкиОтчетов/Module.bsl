
#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьОтбор();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьОтбор()
	
	ОтборДинамическогоСписка = ЖурналОтчетов.КомпоновщикНастроек.Настройки.Отбор;
	
	Ссылка = ОтборДинамическогоСписка.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	
	Ссылка.Использование = Истина;
	Ссылка.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
	Ссылка.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Ссылка");
	
	Ссылка.ПравоеЗначение = Параметры.ДокументыВыгрузки;
	
	ОтборДинамическогоСписка.ИдентификаторПользовательскойНастройки = Строка(Новый УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьОтчет(Команда)
	
	Если Элементы.ЖурналОтчетов.ТекущиеДанные = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru='Выберите отчет для открытия!'"));
		Возврат;
	КонецЕсли;
	Закрыть(Элементы.ЖурналОтчетов.ТекущаяСтрока);
	
КонецПроцедуры

&НаКлиенте
Процедура ЖурналОтчетовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Закрыть(ВыбраннаяСтрока);
	
КонецПроцедуры

#КонецОбласти