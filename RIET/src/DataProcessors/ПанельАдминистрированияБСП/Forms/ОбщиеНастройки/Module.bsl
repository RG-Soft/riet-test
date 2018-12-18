&НаКлиенте
Перем ОбновитьИнтерфейс;

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	// Значения реквизитов формы
	РежимРаботы = ОбщегоНазначенияПовтИсп.РежимРаботыПрограммы();
	РежимРаботы = Новый ФиксированнаяСтруктура(РежимРаботы);
	
	ЧасовойПоясПрограммы = ПолучитьЧасовойПоясИнформационнойБазы();
	Если ПустаяСтрока(ЧасовойПоясПрограммы) Тогда
		ЧасовойПоясПрограммы = ЧасовойПояс();
	КонецЕсли;
	Элементы.ЧасовойПоясПрограммы.СписокВыбора.Добавить(ЧасовойПоясПрограммы);
	
	// СтандартныеПодсистемы.БазоваяФункциональность
	Элементы.ГруппаНастройкаИспользованияПрофилейБезопасности.Видимость = РаботаВБезопасномРежимеСлужебный.ДоступнаНастройкаПрофилейБезопасности() И РежимРаботы.ЭтоАдминистраторСистемы;
	// Конец СтандартныеПодсистемы.БазоваяФункциональность
	
	// СтандартныеПодсистемы.ПолучениеФайловИзИнтернета
	Элементы.ГруппаОткрытьПараметрыПроксиСервера.Видимость = РежимРаботы.КлиентСерверный И РежимРаботы.ЭтоАдминистраторСистемы;
	// Конец СтандартныеПодсистемы.ПолучениеФайловИзИнтернета
	
	// СтандартныеПодсистемы.Интеграция1СБухфон
	Элементы.ГруппаИнтеграция1СБухфон.Видимость = Не РежимРаботы.ЭтоLinuxКлиент;
	// Конец СтандартныеПодсистемы.Интеграция1СБухфон
	
	// СтандартныеПодсистемы.СклонениеПредставленийОбъектов
		
	ЧастиСтроки = Новый Массив;
	ЧастиСтроки.Добавить(ВернутьСтр("ru = 'Разрешить использование сервиса склонения'"));
	ЧастиСтроки.Добавить(" ");	
	ЧастиСтроки.Добавить(Новый ФорматированнаяСтрока("morpher.ru", , , , "http://www.morpher.ru"));
	ЧастиСтроки.Добавить(" ");
	ЧастиСтроки.Добавить(ВернутьСтр("ru = 'для получения представлений объектов в падежах (требуется подключение к Интернет)'"));
	
	Элементы.ПояснениеРазрешениеНаСервисСклонения.Заголовок = Новый ФорматированнаяСтрока(ЧастиСтроки);
	
	// Конец СтандартныеПодсистемы.СклонениеПредставленийОбъектов

	// Обновление состояния элементов.
	
	УстановитьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	ОбновитьИнтерфейсПрограммы();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ЗаголовокПрограммыПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
	СтандартныеПодсистемыКлиент.УстановитьРасширенныйЗаголовокПриложения();
КонецПроцедуры

&НаКлиенте
Процедура ЧасовойПоясПрограммыПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ЧасовойПоясПрограммыНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	Если Элемент.СписокВыбора.Количество() < 2 Тогда
		ЗагрузитьЧасовыеПояса();
	КонецЕсли;
КонецПроцедуры

// СтандартныеПодсистемы.Свойства
&НаКлиенте
Процедура ИспользоватьДополнительныеРеквизитыИСведенияПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры
// Конец СтандартныеПодсистемы.Свойства

// СтандартныеПодсистемы.Интеграция1СБухфон
&НаКлиенте
Процедура Интеграция1СБухфонПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры
// Конец СтандартныеПодсистемы.Интеграция1СБухфон

#КонецОбласти

#Область ОбработчикиКомандФормы

// СтандартныеПодсистемы.Свойства
&НаКлиенте
Процедура ДополнительныеРеквизиты(Команда)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоказатьДополнительныеРеквизиты");
	
	ОткрытьФорму("Справочник.НаборыДополнительныхРеквизитовИСведений.ФормаСписка", ПараметрыФормы, , "ДополнительныеРеквизиты");
	
КонецПроцедуры

&НаКлиенте
Процедура ДополнительныеСведения(Команда)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоказатьДополнительныеСведения");
	
	ОткрытьФорму("Справочник.НаборыДополнительныхРеквизитовИСведений.ФормаСписка", ПараметрыФормы, , "ДополнительныеСведения");
	
КонецПроцедуры
// Конец СтандартныеПодсистемы.Свойства

// СтандартныеПодсистемы.ЭлектроннаяПодпись
&НаКлиенте
Процедура НастройкиЭлектроннойПодписиИШифрования(Команда)
	ОткрытьФорму("ОбщаяФорма.НастройкиЭлектроннойПодписиИШифрования");
КонецПроцедуры
// Конец СтандартныеПодсистемы.ЭлектроннаяПодпись

&НаКлиенте
Процедура ПоказатьВремяТекущегоСеанса(Команда)
	
	ПоказатьПредупреждение(,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ВернутьСтр("ru = 'Время сеанса: %1
				|На сервере: %2
				|На клиенте: %3
				|
				|Время сеанса - это время сервера,
				|приведенное к часовому поясу клиента.'"),
			Формат(ОбщегоНазначенияКлиент.ДатаСеанса(), "ДЛФ=T"),
			Формат(ДатаСервера(), "ДЛФ=T"),
			Формат(ТекущаяДата(), "ДЛФ=T")));
	
КонецПроцедуры

// СтандартныеПодсистемы.БазоваяФункциональность
&НаКлиенте
Процедура ИспользованиеПрофилейБезопасности(Команда)
	
	РаботаВБезопасномРежимеКлиент.ОткрытьДиалогНастройкиИспользованияПрофилейБезопасности();
	
КонецПроцедуры
// Конец СтандартныеПодсистемы.БазоваяФункциональность

// СтандартныеПодсистемы.Интеграция1СБухфон
&НаКлиенте
Процедура Настройка1СБухфон(Команда)
	//ОткрытьФорму("ОбщаяФорма.Настройка1СБухфон");
КонецПроцедуры
// Конец СтандартныеПодсистемы.Интеграция1СБухфон

// СтандартныеПодсистемы.СклонениеПредставленийОбъектов
&НаКлиенте
Процедура НастройкаДоступаКСервисуСклонения(Команда)
	//ОткрытьФорму("ОбщаяФорма.НастройкаДоступаКСервисуMorpher");
КонецПроцедуры
// Конец СтандартныеПодсистемы.СклонениеПредставленийОбъектов

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Клиент

&НаКлиенте
Процедура Подключаемый_ПриИзмененииРеквизита(Элемент, ОбновлятьИнтерфейс = Истина)
	
	КонстантаИмя = ПриИзмененииРеквизитаСервер(Элемент.Имя);
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	Если ОбновлятьИнтерфейс Тогда
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
	Если КонстантаИмя <> "" Тогда
		Оповестить("Запись_НаборКонстант", Новый Структура, КонстантаИмя);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнтерфейсПрограммы()
	
	Если ОбновитьИнтерфейс = Истина Тогда
		ОбновитьИнтерфейс = Ложь;
		ОбщегоНазначенияКлиент.ОбновитьИнтерфейсПрограммы();
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вызов сервера

&НаСервере
Функция ПриИзмененииРеквизитаСервер(ИмяЭлемента)
	
	РеквизитПутьКДанным = Элементы[ИмяЭлемента].ПутьКДанным;
	
	КонстантаИмя = СохранитьЗначениеРеквизита(РеквизитПутьКДанным);
	
	УстановитьДоступность(РеквизитПутьКДанным);
	
	// СтандартныеПодсистемы.СклонениеПредставленийОбъектов
	//Если ИмяЭлемента = "ИспользоватьСервисСклоненияMorpher" Тогда
	//	
	//	СклонениеПредставленийОбъектов.УстановитьДоступностьСервисаСклонения(Истина);
	//	
	//КонецЕсли;
	// Конец СтандартныеПодсистемы.СклонениеПредставленийОбъектов
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	Возврат КонстантаИмя;
	
КонецФункции

&НаСервере
Процедура ЗагрузитьЧасовыеПояса()
	
	Элементы.ЧасовойПоясПрограммы.СписокВыбора.ЗагрузитьЗначения(ПолучитьДопустимыеЧасовыеПояса());
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДатаСервера()
	
	Возврат ТекущаяДата();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Сервер

&НаСервере
Функция СохранитьЗначениеРеквизита(РеквизитПутьКДанным)
	
	// Сохранение значений реквизитов, не связанных с константами напрямую (в отношении один-к-одному).
	Если РеквизитПутьКДанным = "ЧасовойПоясПрограммы" Тогда
		Если ЧасовойПоясПрограммы <> ПолучитьЧасовойПоясИнформационнойБазы() Тогда 
			УстановитьПривилегированныйРежим(Истина);
			Попытка
				ОбщегоНазначения.ЗаблокироватьИБ();
				УстановитьЧасовойПоясИнформационнойБазы(ЧасовойПоясПрограммы);
				ОбщегоНазначения.РазблокироватьИБ();
			Исключение
				ОбщегоНазначения.РазблокироватьИБ();
				ВызватьИсключение;
			КонецПопытки;
			УстановитьПривилегированныйРежим(Ложь);
			УстановитьЧасовойПоясСеанса(ЧасовойПоясПрограммы);
		КонецЕсли;
		Возврат "";
	КонецЕсли;
	
	// Определение имени константы.
	КонстантаИмя = "";
	Если НРег(Лев(РеквизитПутьКДанным, 14)) = НРег("НаборКонстант.") Тогда
		// Если путь к данным реквизита указан через "НаборКонстант".
		КонстантаИмя = Сред(РеквизитПутьКДанным, 15);
	Иначе
		// Определение имени и запись значения реквизита в соответствующей константе из "НаборКонстант".
		// Используется для тех реквизитов формы, которые связаны с константами напрямую (в отношении один-к-одному).
	КонецЕсли;
	
	// Сохранения значения константы.
	Если КонстантаИмя <> "" Тогда
		КонстантаМенеджер = Константы[КонстантаИмя];
		КонстантаЗначение = НаборКонстант[КонстантаИмя];
		
		Если КонстантаМенеджер.Получить() <> КонстантаЗначение Тогда
			КонстантаМенеджер.Установить(КонстантаЗначение);
		КонецЕсли;
	КонецЕсли;
	
	Возврат КонстантаИмя;
	
КонецФункции

&НаСервере
Процедура УстановитьДоступность(РеквизитПутьКДанным = "")
	
	// СтандартныеПодсистемы.Свойства
	Если РеквизитПутьКДанным = "НаборКонстант.ИспользоватьДополнительныеРеквизитыИСведения"
	 ИЛИ РеквизитПутьКДанным = "" Тогда
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ГруппаДополнительныеРеквизитыИСведенияПрочиеНастройки",
			"Доступность",
			НаборКонстант.ИспользоватьДополнительныеРеквизитыИСведения);
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ГруппаДополнительныеРеквизитыИлиСведения",
			"Доступность",
			НаборКонстант.ИспользоватьДополнительныеРеквизитыИСведения);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.Свойства
	
	// СтандартныеПодсистемы.ЭлектроннаяПодпись
	Если РеквизитПутьКДанным = "НаборКонстант.ИспользоватьЭлектронныеПодписи"
	 Или РеквизитПутьКДанным = "НаборКонстант.ИспользоватьШифрование"
	 Или РеквизитПутьКДанным = "" Тогда
		
		Элементы.ГруппаНастройкиЭлектроннойПодписиИШифрования.Доступность =
			НаборКонстант.ИспользоватьЭлектронныеПодписи Или НаборКонстант.ИспользоватьШифрование;
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ЭлектроннаяПодпись
	
	// СтандартныеПодсистемы.БазоваяФункциональность
	Если РеквизитПутьКДанным = "" Тогда
		
		ДоступностьНастройкиПроксиНаСервере = Не ПолучитьФункциональнуюОпцию("ИспользуютсяПрофилиБезопасности");
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ГруппаОткрытьПараметрыПроксиСервера",
			"Доступность",
			ДоступностьНастройкиПроксиНаСервере);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ГруппаНастройкаПроксиСервераНаСервереНедоступнаПриИспользованииПрофилейБезопасности",
			"Видимость",
			НЕ ДоступностьНастройкиПроксиНаСервере);
			
	КонецЕсли;
	// Конец СтандартныеПодсистемы.БазоваяФункциональность
	
	// СтандартныеПодсистемы.Интеграция1СБухфон
	Если РеквизитПутьКДанным = "НаборКонстант.ИспользоватьИнтеграцию1СБухфон" 
		Или РеквизитПутьКДанным = "" Тогда		
		Элементы.ГруппаНастройка1СБухфон.Доступность = НаборКонстант.ИспользоватьИнтеграцию1СБухфон;
	КонецЕсли;
	// Конец СтандартныеПодсистемы.Интеграция1СБухфон
	
	// СтандартныеПодсистемы.СклонениеПредставленийОбъектов
	Если РеквизитПутьКДанным = "НаборКонстант.ИспользоватьСервисСклоненияMorpher" 
		Или РеквизитПутьКДанным = "" Тогда 
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ГруппаНастройкаСклонения",
			"Доступность",
			НаборКонстант.ИспользоватьСервисСклоненияMorpher);
			
	КонецЕсли;		
	// Конец СтандартныеПодсистемы.СклонениеПредставленийОбъектов	
			
КонецПроцедуры

#КонецОбласти
