
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Инвойсы.Параметры.УстановитьЗначениеПараметра("PO", Параметры.PO);
	Инвойсы.Параметры.УстановитьЗначениеПараметра("Invoice", Параметры.Invoice);
	
КонецПроцедуры

&НаКлиенте
Процедура Таблица1Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	СтруктураВыбора = новый Структура;
	СтруктураВыбора.Вставить("Количество", Элемент.ДанныеСтроки(ВыбраннаяСтрока[0]).Количество);
	СтруктураВыбора.Вставить("Сумма", Элемент.ДанныеСтроки(ВыбраннаяСтрока[0]).Сумма);
	СтруктураВыбора.Вставить("НомерГТД", СтрЗаменить(Элемент.ДанныеСтроки(ВыбраннаяСтрока[0]).НомерГТД, "-", "/"));
	СтруктураВыбора.Вставить("Наименование", Элемент.ДанныеСтроки(ВыбраннаяСтрока[0]).НаименованиеРусское);
	
	ОповеститьОВыборе(СтруктураВыбора);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьИнвойс(Команда)
	
	Данные = ЭтаФорма.Элементы.Таблица1.ТекущиеДанные;
	Если Не Данные = Неопределено Тогда
		ОткрытьФорму("Документ.Инвойс.ФормаОбъекта", Новый Структура("Ключ", Данные.СтрокаИнвойса.Инвойс));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Таблица1ВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Количество = 0;
	Для Каждого ЗначениеВыбора Из Значение Цикл
		Количество = Количество + Элемент.ДанныеСтроки(ЗначениеВыбора).Количество; 
	КонецЦикла;
	
	Сумма = 0;
	Для Каждого ЗначениеВыбора Из Значение Цикл
		Сумма = Сумма + Элемент.ДанныеСтроки(ЗначениеВыбора).Сумма; 
	КонецЦикла;
	
	СтруктураВыбора = новый Структура;
	СтруктураВыбора.Вставить("Количество", Количество);
	СтруктураВыбора.Вставить("Сумма", Сумма);
	СтруктураВыбора.Вставить("НомерГТД", СтрЗаменить(Элемент.ДанныеСтроки(ЗначениеВыбора).НомерГТД, "-", "/"));
	СтруктураВыбора.Вставить("Наименование", Элемент.ДанныеСтроки(ЗначениеВыбора).НаименованиеРусское);
	
	ОповеститьОВыборе(СтруктураВыбора);
	
КонецПроцедуры
