
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	ЕстьПравоНаРедактированиеНастроекСервиса = ПроверкаКонтрагентов.ЕстьПравоНаРедактированиеНастроек();
	
	УправлениеЭУ();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	ПриЗакрытииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура НапомнитьПозже(Команда)
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИнформацияОСервисеОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	ПроверкаКонтрагентовКлиент.ОткрытьИнструкциюПоИспользованиюСервиса(СтандартнаяОбработка);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьСервисСейчас(Команда)
	ВключитьСервисСейчасСервер();
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура БольшеНеПоказывать(Команда)
	
	ПроверкаКонтрагентовВызовСервера.ЗапомнитьЧтоБольшеНеНужноПоказыватьПредложениеИспользоватьСервис();
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВключитьСервисСейчасСервер()
	ПроверкаКонтрагентов.СохранитьЗначенияНастроек(Истина);
	ПроверкаКонтрагентов.ПроверитьКонтрагентовПослеВключенияПроверкиФоновоеЗадание();
КонецПроцедуры

&НаСервере
Процедура УправлениеЭУ()
	
	// В зависимости от наличия административных прав будут доступны разные элементы управления
	Элементы.ИнформацияОНеобходимостиОбратитьсяКАдминистратору.Видимость 	= НЕ ЕстьПравоНаРедактированиеНастроекСервиса;
	Элементы.ВключитьСервисСейчас.Видимость 								= ЕстьПравоНаРедактированиеНастроекСервиса;
	Элементы.ПредупреждениеПроТестовыйРежим.Заголовок 						= ПроверкаКонтрагентов.ТекстПредупрежденияПроТестовыйРежимРаботыСервиса();
	
	// Кнопка по умолчанию
	Элементы.ВключитьСервисСейчас.КнопкаПоУмолчанию = ЕстьПравоНаРедактированиеНастроекСервиса;
	Элементы.НапомнитьПозже.КнопкаПоУмолчанию 		= НЕ  ЕстьПравоНаРедактированиеНастроекСервиса;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗакрытииНаСервере()
	
	// Сохраняем дату последнего отображения
	ПроверкаКонтрагентов.СохранитьДатуПоследнегоОтображенияПредложенияПодключиться();

КонецПроцедуры

#КонецОбласти
