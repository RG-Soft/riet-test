
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
	ПоставляемыеНастройки = Справочники.ПрограммыЭлектроннойПодписиИШифрования.ПоставляемыеНастройкиПрограмм();
	Для каждого ПоставляемаяНастройка Из ПоставляемыеНастройки Цикл
		Элементы.Наименование.СписокВыбора.Добавить(ПоставляемаяНастройка.Представление);
	КонецЦикла;
	Элементы.Наименование.СписокВыбора.Добавить("", ВернутьСтр("ru = '<Другая программа>'"));
	
	// Заполнение нового объекта по поставляемой настройке.
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Отбор = Новый Структура("Идентификатор", Параметры.ИдентификаторПоставляемойНастройки);
		Строки = ПоставляемыеНастройки.НайтиСтроки(Отбор);
		Если Строки.Количество() > 0 Тогда
			ЗаполнитьЗначенияСвойств(Объект, Строки[0]);
			Объект.Наименование = Строки[0].Представление;
			Элементы.Наименование.ТолькоПросмотр = Истина;
			Элементы.ИмяПрограммы.ТолькоПросмотр = Истина;
			Элементы.ТипПрограммы.ТолькоПросмотр = Истина;
		КонецЕсли;
	КонецЕсли;
	
	// Заполнение списков алгоритмов.
	Отбор = Новый Структура("ИмяПрограммы, ТипПрограммы", Объект.ИмяПрограммы, Объект.ТипПрограммы);
	Строки = ПоставляемыеНастройки.НайтиСтроки(Отбор);
	ПоставляемаяНастройка = ?(Строки.Количество() = 0, Неопределено, Строки[0]);
	ЗаполнитьСпискиВыбораАлгоритмов(ПоставляемаяНастройка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗаполнитьАлгоритмыВыбраннойПрограммы();
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	// Требуется для обновления списка программ и
	// их параметров на сервере и на клиенте.
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Оповестить("Запись_ПрограммыЭлектроннойПодписиИШифрования", Новый Структура, Объект.Ссылка);
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	Запрос.УстановитьПараметр("ИмяПрограммы", Объект.ИмяПрограммы);
	Запрос.УстановитьПараметр("ТипПрограммы", Объект.ТипПрограммы);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	Справочник.ПрограммыЭлектроннойПодписиИШифрования КАК ПрограммыЭлектроннойПодписиИШифрования
	|ГДЕ
	|	ПрограммыЭлектроннойПодписиИШифрования.Ссылка <> &Ссылка
	|	И ПрограммыЭлектроннойПодписиИШифрования.ИмяПрограммы = &ИмяПрограммы
	|	И ПрограммыЭлектроннойПодписиИШифрования.ТипПрограммы = &ТипПрограммы";
	
	Если Не Запрос.Выполнить().Пустой() Тогда
		Отказ = Истина;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ВернутьСтр("ru = 'Программа с указанным именем и типом уже добавлена в список.'"),
			,
			"Объект.ИмяПрограммы");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	
	ЗаполнитьНастройкиВыбраннойПрограммы(Объект.Наименование);
	ЗаполнитьАлгоритмыВыбраннойПрограммы();
	
КонецПроцедуры

&НаКлиенте
Процедура НаименованиеОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ИнформацияМодуля = Неопределено;
	
	Если ВыбранноеЗначение = "" Тогда
		Объект.Наименование = "";
		Объект.ИмяПрограммы = "";
		Объект.ТипПрограммы = "";
		Объект.АлгоритмПодписи = "";
		Объект.АлгоритмХеширования = "";
		Объект.АлгоритмШифрования = "";
	КонецЕсли;
	
	ЗаполнитьНастройкиВыбраннойПрограммы(ВыбранноеЗначение);
	ЗаполнитьАлгоритмыВыбраннойПрограммы();
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяПрограммыПриИзменении(Элемент)
	
	ЗаполнитьАлгоритмыВыбраннойПрограммы();
	
КонецПроцедуры

&НаКлиенте
Процедура ТипПрограммыПриИзменении(Элемент)
	
	ЗаполнитьАлгоритмыВыбраннойПрограммы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьПометкуУдаления(Команда)
	
	Если Не Модифицированность Тогда
		УстановитьПометкуУдаленияЗавершение();
		Возврат;
	КонецЕсли;
	
	ПоказатьВопрос(
		Новый ОписаниеОповещения("УстановитьПометкуУдаленияПослеОтветаНаВопрос", ЭтотОбъект),
		ВернутьСтр("ru = 'Для установки отметки удаления необходимо записать внесенные Вами изменения.
		           |Записать данные?'"), РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьНастройкиВыбраннойПрограммы(Представление)
	
	ПоставляемыеНастройки = Справочники.ПрограммыЭлектроннойПодписиИШифрования.ПоставляемыеНастройкиПрограмм();
	
	ПоставляемаяНастройка = ПоставляемыеНастройки.Найти(Представление, "Представление");
	Если ПоставляемаяНастройка <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(Объект, ПоставляемаяНастройка);
		Объект.Наименование = ПоставляемаяНастройка.Представление;
	КонецЕсли;
	
	ЗаполнитьСпискиВыбораАлгоритмов(ПоставляемаяНастройка);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСпискиВыбораАлгоритмов(ПоставляемаяНастройка)
	
	АлгоритмыПодписиПоставляемые.Очистить();
	АлгоритмыХешированияПоставляемые.Очистить();
	АлгоритмыШифрованияПоставляемые.Очистить();
	
	Если ПоставляемаяНастройка = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	АлгоритмыПодписиПоставляемые.ЗагрузитьЗначения(ПоставляемаяНастройка.АлгоритмыПодписи);
	АлгоритмыХешированияПоставляемые.ЗагрузитьЗначения(ПоставляемаяНастройка.АлгоритмыХеширования);
	АлгоритмыШифрованияПоставляемые.ЗагрузитьЗначения(ПоставляемаяНастройка.АлгоритмыШифрования);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьАлгоритмыВыбраннойПрограммы()
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	НачатьПодключениеРасширенияРаботыСКриптографией(Новый ОписаниеОповещения(
		"ЗаполнитьАлгоритмыВыбраннойПрограммыПослеПодключенияРасширенияРаботыСКриптографией", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры ЗаполнитьАлгоритмыВыбраннойПрограммы.
&НаКлиенте
Процедура ЗаполнитьАлгоритмыВыбраннойПрограммыПослеПодключенияРасширенияРаботыСКриптографией(Подключено, Контекст) Экспорт
	
	Если Не Подключено Тогда
		ЗаполнитьАлгоритмыВыбраннойПрограммыПослеПолученияИнформации(Неопределено, Контекст);
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		ПерсональныеНастройки = ЭлектроннаяПодписьКлиентСервер.ПерсональныеНастройки();
		ПутьКПрограмме = ПерсональныеНастройки.ПутиКПрограммамЭлектроннойПодписиИШифрования.Получить(
			Объект.Ссылка);
	Иначе
		ПутьКПрограмме = "";
	КонецЕсли;
	
	СредстваКриптографии.НачатьПолучениеИнформацииМодуляКриптографии(Новый ОписаниеОповещения(
			"ЗаполнитьАлгоритмыВыбраннойПрограммыПослеПолученияИнформации", ЭтотОбъект, ,
			"ЗаполнитьАлгоритмыВыбраннойПрограммыПослеОшибкиПолученияИнформации", ЭтотОбъект),
		Объект.ИмяПрограммы, ПутьКПрограмме, Объект.ТипПрограммы);
	
КонецПроцедуры

// Продолжение процедуры ЗаполнитьАлгоритмыВыбраннойПрограммы.
&НаКлиенте
Процедура ЗаполнитьАлгоритмыВыбраннойПрограммыПослеОшибкиПолученияИнформации(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	ЗаполнитьАлгоритмыВыбраннойПрограммыПослеПолученияИнформации(Неопределено, Контекст);
	
КонецПроцедуры

// Продолжение процедуры ЗаполнитьАлгоритмыВыбраннойПрограммы.
&НаКлиенте
Процедура ЗаполнитьАлгоритмыВыбраннойПрограммыПослеПолученияИнформации(ИнформацияМодуля, Контекст) Экспорт
	
	// Если менеджер криптографии не доступен и не из числа поставляемых,
	// тогда имена алгоритмов заполняются вручную.
	
	Если ИнформацияМодуля <> Неопределено
	   И Объект.ИмяПрограммы <> ИнформацияМодуля.Имя
	   И Не ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		
		ИнформацияМодуля = Неопределено;
	КонецЕсли;
	
	Если ИнформацияМодуля = Неопределено Тогда
		Элементы.АлгоритмПодписи.СписокВыбора.ЗагрузитьЗначения(
			АлгоритмыПодписиПоставляемые.ВыгрузитьЗначения());
		
		Элементы.АлгоритмХеширования.СписокВыбора.ЗагрузитьЗначения(
			АлгоритмыХешированияПоставляемые.ВыгрузитьЗначения());
		
		Элементы.АлгоритмШифрования.СписокВыбора.ЗагрузитьЗначения(
			АлгоритмыШифрованияПоставляемые.ВыгрузитьЗначения());
	Иначе
		Элементы.АлгоритмПодписи.СписокВыбора.ЗагрузитьЗначения(
			Новый Массив(ИнформацияМодуля.АлгоритмыПодписи));
		
		Элементы.АлгоритмХеширования.СписокВыбора.ЗагрузитьЗначения(
			Новый Массив(ИнформацияМодуля.АлгоритмыХеширования));
		
		Элементы.АлгоритмШифрования.СписокВыбора.ЗагрузитьЗначения(
			Новый Массив(ИнформацияМодуля.АлгоритмыШифрования));
	КонецЕсли;
	
	Элементы.АлгоритмПодписи.КнопкаВыпадающегоСписка =
		Элементы.АлгоритмПодписи.СписокВыбора.Количество() <> 0;
	
	Элементы.АлгоритмХеширования.КнопкаВыпадающегоСписка =
		Элементы.АлгоритмХеширования.СписокВыбора.Количество() <> 0;
	
	Элементы.АлгоритмШифрования.КнопкаВыпадающегоСписка =
		Элементы.АлгоритмШифрования.СписокВыбора.Количество() <> 0;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометкуУдаленияПослеОтветаНаВопрос(Ответ, Неопределен) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Если Не Записать() Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПометкуУдаленияЗавершение();
	
КонецПроцедуры
	
&НаКлиенте
Процедура УстановитьПометкуУдаленияЗавершение()
	
	Объект.ПометкаУдаления = Не Объект.ПометкаУдаления;
	Записать();
	
	Оповестить("Запись_ПрограммыЭлектроннойПодписиИШифрования", Новый Структура, Объект.Ссылка);
	
КонецПроцедуры

#КонецОбласти
