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
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Справочник не предназначен для ручного заполнения!'");
		Сообщение.Сообщить();
		Отказ = Истина;
		Возврат;
		
	КонецЕсли;

	Элементы.НадписьПомеченНаУдаление.Видимость = Объект.ПометкаУдаления;
	
	Если ТипЗнч(Объект.ОтчетСсылка) = Тип("ДокументСсылка.РегламентированныйОтчет") Тогда
		ОтчетПредставление = РегламентированнаяОтчетностьКлиентСервер.ПредставлениеДокументаРеглОтч(Объект.ОтчетСсылка);
	Иначе // электронное представление
		ОтчетПредставление = Объект.ОтчетСсылка.Наименование;
	КонецЕсли;
	
	ДатаОтправки = Объект.ДатаОтправки;
	ДатаЗакрытия = НСтр("ru = '<не завершена>'");
	ДатаОбновления = НСтр("ru = '<не определено>'");
	ОбновитьФорму();
	
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиВызовСервера.СкрытьЭлементыФормыПриИспользованииОднойОрганизации(ЭтаФорма, "ГруппаСубъектыПереписки");
	
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
		Если Объект.СтатусПроверкиНаПортале = Перечисления.СтатусыОтправки.Сдан Тогда
			Элементы.КартинкаПодтверждениеОтправки.Картинка = БиблиотекаКартинок.ЗолотойШар;
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСиний;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Промежуточный протокол обработки порталом получен, отчет ждет доставки в управление'");
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		ИначеЕсли ПротоколЗаполнен(Объект.Ссылка) Тогда
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСерый;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Промежуточный протокол обработки порталом получен'");
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		Иначе
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСерый;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Протокол обработки пакета отсутствует'");
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Ложь;
		КонецЕсли;
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
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Протокол ошибок получен'");
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСиний;
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Сдан Тогда
			Элементы.КартинкаСтатусОтправки.Картинка = БиблиотекаКартинок.ПисьмоПодтверждениеПолучено;
			Элементы.НадписьСтатусОтправки.Заголовок = НСтр("ru = 'Протокол о сдаче отчета получен'");
			Элементы.НадписьСтатусОтправки.ЦветТекста = ЦветСиний;
			Элементы.НадписьСтатусОтправки.ГиперСсылка = Истина;
		КонецЕсли;
	КонецЕсли;
	
	ОбновитьМеню();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьМеню()
	
	КнопкаВыгрузитьПротокол = Элементы.Найти("ФормаВыгрузитьПротокол");
	
	Если Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Отправлен Тогда
		КнопкаВыгрузитьПротокол.Видимость = (Объект.СтатусПроверкиНаПортале = Перечисления.СтатусыОтправки.Сдан ИЛИ ПротоколЗаполнен(Объект.Ссылка));
	ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.НеПринят Тогда
		КнопкаВыгрузитьПротокол.Видимость = Истина;
	ИначеЕсли Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Сдан
		ИЛИ Объект.СтатусОтправки = Перечисления.СтатусыОтправки.ПринятЕстьОшибки Тогда
		КнопкаВыгрузитьПротокол.Видимость = Истина;
	КонецЕсли;
	
	//кнопка Обновить
	КнопкаОбновить = Элементы.Найти("ФормаОбновить");
	КнопкаОбновить.Видимость = (Объект.СтатусОтправки = Перечисления.СтатусыОтправки.Отправлен);
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбновитьЗавершение", ЭтотОбъект);
	КонтекстЭДОКлиент.ОбновитьРезультатКонкретнойОтправкиРПН(ЭтаФорма, Объект.Ссылка, ОписаниеОповещения);
		
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ОбновитьДанныеФормыНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтчетПредставлениеНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПоказатьЗначение(,Объект.ОтчетСсылка);
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьСтатусОтправкиНажатие(Элемент)
	
	КонтекстЭДОКлиент.ПоказатьПротоколОбработкиПоСсылкеИсточникаДляРПН(Объект.Ссылка);
	
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

&НаКлиенте
Процедура ВыгрузитьПротокол(Команда)
	
	Адрес = ПолучитьАдресФайлаПротокола(Объект.Ссылка);
	ИмяФайлаПакетаДоТочки = Объект.ИмяФайлаПакета;
	ПозицияТочки = СтрНайти(ИмяФайлаПакетаДоТочки, ".");
	Если ПозицияТочки > 0 Тогда
		ИмяФайлаПакетаДоТочки = Лев(ИмяФайлаПакетаДоТочки, ПозицияТочки - 1);
	КонецЕсли;
	
	ПолучитьФайл(Адрес, НСтр("ru = 'Протокол'") + ИмяФайлаПакетаДоТочки + ".html");
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьПакет(Команда)
	
	Адрес = ПолучитьАдресФайлаПакета(Объект.Ссылка);
	ПолучитьФайл(Адрес, Объект.ИмяФайлаПакета);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПротоколЗаполнен(ОтправкаСсылка)
	
	Возврат ЗначениеЗаполнено(ОтправкаСсылка.Протокол.Получить());
	
КонецФункции