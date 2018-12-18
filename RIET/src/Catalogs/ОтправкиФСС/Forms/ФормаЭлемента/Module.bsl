&НаКлиенте
Перем КонтекстЭДОКлиент;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если Параметры.Ключ.Пустая() Тогда
		
		//Создается новый объект
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Справочник не предназначен для ручного заполнения!'"));
		Отказ = Истина;
		Возврат;
		
	КонецЕсли;

	Элементы.НадписьПомеченНаУдаление.Видимость = Объект.ПометкаУдаления;
	
	ОтчетСсылка = Объект.ОтчетСсылка;
	ТипЗнчСсылкаНаОтчет = ТипЗнч(ОтчетСсылка);
	ЭтоРеестрСведений = ДокументооборотСФССКлиентСервер.ЭтоРеестрСведенийНаВыплатуПособийФСС(ОтчетСсылка);

	Если ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка.РегламентированныйОтчет") Тогда
		ОтчетПредставление = РегламентированнаяОтчетностьКлиентСервер.ПредставлениеДокументаРеглОтч(ОтчетСсылка);
	ИначеЕсли ЭтоРеестрСведений Тогда
		ОтчетПредставление = Строка(ОтчетСсылка);	
	ИначеЕсли ТипЗнчСсылкаНаОтчет = Тип("СправочникСсылка.ЭлектронныеПредставленияРегламентированныхОтчетов") Тогда
		// электронное представление
		ОтчетПредставление = ОтчетСсылка.Наименование;
	Иначе
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	ДатаОтправки = Объект.ДатаОтправки;
	ДатаЗакрытия = НСтр("ru = '<не завершена>'");
	ДатаОбновления = НСтр("ru = '<не определено>'");
	ОбновитьФорму();
	
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиВызовСервера.СкрытьЭлементыФормыПриИспользованииОднойОрганизации(ЭтаФорма, "НадписьОрганизация");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриОткрытииЗавершение", ЭтотОбъект);
	
	ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытииЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьДанныеФормыНаСервере()
	
	Прочитать();
	ОбновитьФорму();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьФорму()
		
	ЦветСерый = Новый Цвет(128, 128, 128);
	ЦветСиний = Новый Цвет(0, 0, 255);
	
	ПустаяДата = Дата(1,1,1);
	
	ДатаОбновления = ?(Объект.ДатаПолученияРезультата = ПустаяДата, НСтр("ru = '<не определено>'"), Объект.ДатаПолученияРезультата);
	
	Если Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Отправлен Тогда
		Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Протокол обработки пакета отсутствует'");
		Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСерый;
		Элементы.НадписьСтатусОтправки.ГиперСсылка = Ложь;
	Иначе
		Элементы.КартинкаПодтверждениеОтправки.Картинка = БиблиотекаКартинок.ЗеленыйШар;
		ДатаЗакрытия =  Объект.ДатаЗакрытия;
		
		Если Объект.СтатусОтправки = Перечисления.СтатусыОтправки.НеПринят Тогда
			Элементы.КартинкаСтатусОтправки.Картинка = БиблиотекаКартинок.РегламентированныйОтчетНеПринят;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Протокол ошибок получен'");
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСиний;
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.ПринятЕстьОшибки Тогда
			Элементы.КартинкаСтатусОтправки.Картинка = БиблиотекаКартинок.ПисьмоПодтверждениеПолучено;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Квитанция о сдаче отчета получена, протокол ошибок получен'");
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСиний;
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Сдан Тогда
			Элементы.КартинкаСтатусОтправки.Картинка = БиблиотекаКартинок.ПисьмоПодтверждениеПолучено;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Квитанция о сдаче отчета получена'");
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСиний;
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		КонецЕсли;
	КонецЕсли;
	
	ОбновитьМеню();
КонецПроцедуры

&НаСервере
Процедура ОбновитьМеню()
	
	КнопкаВыгрузитьКвитанцию = Элементы.Найти("ФормаВыгрузитьКвитанцию");
	КнопкаВыгрузитьПротокол = Элементы.Найти("ФормаВыгрузитьПротокол");
	
	Если Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Отправлен Тогда
		КнопкаВыгрузитьКвитанцию.Видимость 	= Ложь;
		КнопкаВыгрузитьПротокол.Видимость 	= Ложь;
	ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.НеПринят Тогда
		КнопкаВыгрузитьКвитанцию.Видимость 	= Ложь;
		КнопкаВыгрузитьПротокол.Видимость 	= Истина;
	ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Сдан 
		ИЛИ Объект.СтатусОтправки = Перечисления.СтатусыОтправки.ПринятЕстьОшибки Тогда
		КнопкаВыгрузитьКвитанцию.Видимость 	= Истина;
		КнопкаВыгрузитьПротокол.Видимость 	= Истина;
	КонецЕсли;
	
	//кнопка Обновить
	КнопкаОбновить = Элементы.Найти("ФормаОбновить");
	КнопкаОбновить.Видимость = (Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Отправлен)
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбновитьЗавершение", ЭтотОбъект);
	КонтекстЭДОКлиент.ОбновитьРезультатКонкретнойОтправкиФСС(Объект.Ссылка,,ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ОбновитьДанныеФормыНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтчетПредставлениеНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПоказатьЗначение(, Объект.ОтчетСсылка);
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьСтатусОтправкиНажатие(Элемент)
	
	КонтекстЭДОКлиент.ПоказатьПротоколОбработкиПоСсылкеИсточникаДляФСС(Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьПервичноеСообщениеНажатие(Элемент)
	
	Адрес = ПолучитьАдресФайлаПакета(Объект.Ссылка);
	ПолучитьФайл(Адрес, Объект.ИмяФайлаПакета);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьАдресФайлаПакета(ОтправкаСсылка)
	
	Возврат ПоместитьВоВременноеХранилище(ОтправкаСсылка.ЗашифрованныйПакет.Получить());
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьАдресФайлаПротокола(ОтправкаСсылка)
	
	СтрПротокол = ОтправкаСсылка.Протокол.Получить();
	ВременныйФайл = ПолучитьИмяВременногоФайла();
	Текст = Новый ЗаписьТекста(ВременныйФайл, КодировкаТекста.UTF8);
	Текст.Записать(СтрПротокол);
	Текст.Закрыть();
	
	Возврат ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ВременныйФайл));
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьАдресФайлаКвитанции(ОтправкаСсылка)
	
	Возврат ПоместитьВоВременноеХранилище(ОтправкаСсылка.Квитанция.Получить());
	
КонецФункции

&НаКлиенте
Процедура ВыгрузитьКвитанцию(Команда)
	
	Адрес = ПолучитьАдресФайлаКвитанции(Объект.Ссылка);
	ПолучитьФайл(Адрес, Объект.ИдентификаторОтправкиНаСервере + ".p7e");
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьПротокол(Команда)
	
	Адрес = ПолучитьАдресФайлаПротокола(Объект.Ссылка);
	ПолучитьФайл(Адрес, НСтр("ru = 'Протокол'") + "_" + Объект.ИдентификаторОтправкиНаСервере + ".html");
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьПакет(Команда)
	
	Адрес = ПолучитьАдресФайлаПакета(Объект.Ссылка);
	ПолучитьФайл(Адрес, Объект.ИмяФайлаПакета);
	
КонецПроцедуры
