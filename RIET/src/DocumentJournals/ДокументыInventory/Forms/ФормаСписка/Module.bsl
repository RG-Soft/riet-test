////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМЫ

 &НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	Форма.Элементы.ПоказатьСкрытьПроводки.Пометка = Форма.ПоказыватьПроводки;
	Форма.Элементы.Проводки.Видимость = Форма.ПоказыватьПроводки;
	Форма.Элементы.ПоказатьСкрытьПартии.Пометка = Форма.ПоказыватьПартии;
	Форма.Элементы.Партии.Видимость = Форма.ПоказыватьПартии;

КонецПроцедуры

&НаКлиенте
Функция ПолучитьДокумент()
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда
		Предупреждение(НСтр("ru = 'Не выбран документ'"));
		Возврат Неопределено;
	КонецЕсли;
	
	ТекДокумент = ТекДанные.Ссылка;
	Если НЕ ЗначениеЗаполнено(ТекДокумент) Тогда
		Предупреждение(НСтр("ru = 'Не выбран документ'"));
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ТекДокумент;
	
КонецФункции

&НаКлиенте
Процедура ОбновитьПроводки()

	Регистратор = ?(Элементы.Список.ТекущиеДанные = Неопределено, Неопределено, Элементы.Список.ТекущиеДанные.Ссылка);
	Проводки.Параметры.УстановитьЗначениеПараметра("Регистратор", Регистратор);

КонецПроцедуры

 ////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура ПоказатьСкрытьПроводки(Команда)
	
	ПоказыватьПроводки = НЕ ПоказыватьПроводки;
	УправлениеФормой(ЭтаФорма);
	Если ПоказыватьПроводки Тогда
		ПодключитьОбработчикОжидания("ОбновитьПроводки", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСкрытьПартии(Команда)
	ПоказыватьПартии = НЕ ПоказыватьПартии;
	УправлениеФормой(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ОтборСегментПриИзменении(Элемент)
	
	ОтборыСписковКлиентСервер.ИзменитьЭлементОтбораСписка(Список, "Segment", ОтборСегмент, ЗначениеЗаполнено(ОтборСегмент));
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборTaxRegistrationПриИзменении(Элемент)
	
	ОтборыСписковКлиентСервер.ИзменитьЭлементОтбораСписка(Список, "TaxRegistration", ОтборTaxRegistration, ЗначениеЗаполнено(ОтборTaxRegistration));
	
КонецПроцедуры

 &НаКлиенте
Процедура ОтборLocationПриИзменении(Элемент)
	ОтборыСписковКлиентСервер.ИзменитьЭлементОтбораСписка(Список, "Location", ОтборLocation, ЗначениеЗаполнено(ОтборLocation));
КонецПроцедуры

&НаКлиенте
Процедура ОтборReferenceПриИзменении(Элемент)
	
	ОтборыСписковКлиентСервер.ИзменитьЭлементОтбораСписка(Список, "Reference", ОтборReference, ЗначениеЗаполнено(ОтборReference), ВидСравненияКомпоновкиДанных.Содержит);

КонецПроцедуры

&НаКлиенте                                                               
Процедура ОтборIntDocTypeПриИзменении(Элемент)
	ОтборыСписковКлиентСервер.ИзменитьЭлементОтбораСписка(Список, "IctDocType", ОтборIntDocType, ЗначениеЗаполнено(ОтборIntDocType), ВидСравненияКомпоновкиДанных.Содержит);
КонецПроцедуры

&НаКлиенте
Процедура ОтборFGПриИзменении(Элемент)                                                                       
	ОтборыСписковКлиентСервер.ИзменитьЭлементОтбораСписка(Список, "HasFinishedGoods", ОтборFG, ЗначениеЗаполнено(ОтборFG));
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭтаФорма.ПоказыватьПроводки = Ложь;
	ЭтаФорма.ПоказыватьПартии = Ложь;
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры
 	
&НаКлиенте
Процедура ПриОткрытии(Отказ)

	// при открытии формы надо сразу передать в список Проводки параметр
	Регистратор = ?(Элементы.Список.ТекущиеДанные = Неопределено, Неопределено, Элементы.Список.ТекущиеДанные.Ссылка);
	Проводки.Параметры.УстановитьЗначениеПараметра("Регистратор", Регистратор);
	Партии.Параметры.УстановитьЗначениеПараметра("Регистратор", Регистратор);


КонецПроцедуры

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	Если ПоказыватьПроводки Тогда
		ПодключитьОбработчикОжидания("ОбновитьПроводки", 0.1, Истина);
	КонецЕсли;
	
		Если ПоказыватьПартии Тогда
		ПодключитьОбработчикОжидания("ОбновитьПроводки", 0.1, Истина);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ЗагрузкаИзLawson(Команда)
	
	ОткрытьФорму("Обработка.ЗагрузкаInventoryИзLawson.Форма");
	
КонецПроцедуры






