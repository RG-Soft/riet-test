&НаКлиенте
Перем КонтекстЭДОКлиент;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	ВидДокумента 				= Параметры.ВидДокумента;
	ИННКППОрганизации 			= Параметры.ИННКППОрганизации;
	ИдентификаторФормыВладельца = Параметры.ИдентификаторФормыВладельца;
	
	СписокВыбораВидовДокументов = Элементы.ВидДокумента.СписокВыбора;
	СписокВыбораВидовДокументов.Добавить(Перечисления.ВидыПредставляемыхДокументов.СчетФактура);
	СписокВыбораВидовДокументов.Добавить(Перечисления.ВидыПредставляемыхДокументов.АктПриемкиСдачиРабот);
	СписокВыбораВидовДокументов.Добавить(Перечисления.ВидыПредставляемыхДокументов.ТоварнаяНакладнаяТОРГ12);
	СписокВыбораВидовДокументов.Добавить(Перечисления.ВидыПредставляемыхДокументов.КорректировочныйСчетФактура);
	
	СписокВыбораНаправлений = Элементы.Направление.СписокВыбора;
	СписокВыбораНаправлений.Добавить("Входящий", 	"Входящие");
	СписокВыбораНаправлений.Добавить("Исходящий", 	"Исходящие");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриОткрытииЗавершение", ЭтотОбъект);
	
	ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытииЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЗагрузитьФайлИлиЗакрыть();

КонецПроцедуры

&НаКлиенте
Процедура ВидДокументаПриИзменении(Элемент)
	
	ЗаполнитьПоОтборамТаблицуОтображаемыеДокументы();
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	ЗаполнитьПоОтборамТаблицуОтображаемыеДокументы();
	
КонецПроцедуры

&НаКлиенте
Процедура НаправлениеПриИзменении(Элемент)
	
	ЗаполнитьПоОтборамТаблицуОтображаемыеДокументы();
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаКлиенте
Процедура СнятьФлажки(Команда)
	
	Для Каждого Строка Из ОтображаемыеДокументы Цикл
		Строка.Выбрать = Ложь;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	
	Для Каждого Строка Из ОтображаемыеДокументы Цикл
		Строка.Выбрать = Истина;
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура Загрузить(Команда)
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("Выбрать", Истина);
	
	СтрокиВыбранныхДокументов = ОтображаемыеДокументы.НайтиСтроки(ПараметрыОтбора);
	
	Если СтрокиВыбранныхДокументов.Количество() = 0 Тогда
		ТекстСообщения = ВернутьСтр("ru = 'Для загрузки необходимо выбрать хотя бы один документ.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;	
	
	СтруктураРезультата = Новый Структура;
	АдресТЗВыбранныеДокументы = ПоместитьВХранилищеТаблицуВыбранныхДокументов();
	СтруктураРезультата.Вставить("АдресТЗЗагруженныеДокументы", АдресТЗВыбранныеДокументы);
	СтруктураРезультата.Вставить("ПолноеИмяФайлаОбмена", ПолноеИмяФайлаОбменаНаСервере);
	
	ОповеститьОВыборе(СтруктураРезультата);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлИлиЗакрыть()
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьФайлИлиЗакрытьПродолжение", ЭтотОбъект);
	КонтекстЭДОКлиент.ПоддерживаетсяИспользованиеРасширенияРаботыСФайлами(ОписаниеОповещения, Истина);
		
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлИлиЗакрытьПродолжение(Результат, ДополнительныеПараметры) Экспорт
	
	ПоддерживаетсяИспользованиеРасширенияРаботыСФайлами = Результат;
	
	НачалоИмениФайла = "EDI_" + ИННКППОрганизации + "_";
	ФайлыБылиВыбраны = Ложь;
	Если ПоддерживаетсяИспользованиеРасширенияРаботыСФайлами Тогда
		
		ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		ДиалогВыбора.Заголовок = "Выберите файл для загрузки";
		ДиалогВыбора.МножественныйВыбор = Ложь;
		ДиалогВыбора.ПроверятьСуществованиеФайла = Истина;

		ДиалогВыбора.Фильтр = "ZIP архив(" + НачалоИмениФайла + "*.zip)|" + НачалоИмениФайла + "*.zip";
		ФайлыБылиВыбраны = ДиалогВыбора.Выбрать();
		
		Если ФайлыБылиВыбраны Тогда
			ВыбранныеФайлы = ДиалогВыбора.ВыбранныеФайлы;

			ПолноеИмяФайлаОбмена = ВыбранныеФайлы[0]; // для отображения на форме

			// составляем массив с объектами Файл
			МассивФайлов = Новый Массив;
			Для Каждого ЭлФайл Из ВыбранныеФайлы Цикл
				Файл = Новый Файл(ЭлФайл);
				МассивФайлов.Добавить(Новый Структура("Имя, ПолноеИмя, Расширение, АдресДанных", Файл.Имя, Файл.ПолноеИмя, Файл.Расширение));
			КонецЦикла;
			
			ПомещаемыеФайлы = Новый Массив;
			Для Каждого ЭлФайл Из МассивФайлов Цикл 
				ОписаниеФайла = Новый ОписаниеПередаваемогоФайла(ЭлФайл.ПолноеИмя); 
				ПомещаемыеФайлы.Добавить(ОписаниеФайла);
			КонецЦикла;
			ПомещенныеФайлы = Новый Массив;
			
			Если ПоместитьФайлы(ПомещаемыеФайлы, ПомещенныеФайлы, , Ложь, УникальныйИдентификатор) Тогда
				
				Для каждого ЭлФайл Из МассивФайлов Цикл
					Для каждого ОписаниеПереданногоФайла Из ПомещенныеФайлы Цикл
						Если ОписаниеПереданногоФайла.Имя = ЭлФайл.ПолноеИмя Тогда
							ЭлФайл.АдресДанных = ОписаниеПереданногоФайла.Хранение;
							Прервать;
						КонецЕсли;
					КонецЦикла;
				КонецЦикла; 
				
			КонецЕсли;
			
			АдресФайлаОбменаВоВременномХранилище = МассивФайлов[0].АдресДанных;
			
			Если ЗагрузитьФайлНаСервере(АдресФайлаОбменаВоВременномХранилище) Тогда
				Возврат;
			Иначе
				Закрыть();
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		НачальноеИмяФайла = "";
		АдресДанных = "";
		ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьФайлИлиЗакрытьЗавершение", ЭтотОбъект, НачалоИмениФайла);
		НачатьПомещениеФайла(ОписаниеОповещения, АдресДанных, НачальноеИмяФайла, Истина, УникальныйИдентификатор);
		Возврат;	
	КонецЕсли;
		
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлИлиЗакрытьЗавершение(ФайлыБылиВыбраны, АдресДанных, ВыбранноеИмяФайла, НачалоИмениФайла) Экспорт
	
	Если НЕ КонтекстЭДОКлиент.ВыбранКорректныйФайл(ВыбранноеИмяФайла, ".zip") Тогда
		ТекстПредупреждения = ВернутьСтр("ru = 'Имя выбираемого файла должно иметь формат %1*.zip'");
		ТекстПредупреждения = СтрЗаменить(ТекстПредупреждения, "%1", НачалоИмениФайла);
		ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьФайлИлиЗакрытьЗавершение", ЭтотОбъект);
		ПоказатьПредупреждение(ОписаниеОповещения, ТекстПредупреждения);
		Возврат;
	КонецЕсли;
	
	Если ФайлыБылиВыбраны Тогда 
		
		ПолноеИмяФайлаОбмена = ВыбранноеИмяФайла; // для отображения на форме
		// составляем массив с объектами Файл
		МассивФайлов = Новый Массив;
		Файл = КонтекстЭДОКлиент.СвойстваФайла(АдресДанных, ВыбранноеИмяФайла);
		МассивФайлов.Добавить(Новый Структура("Имя, ПолноеИмя, Расширение, АдресДанных", Файл.Имя, Файл.ПолноеИмя, Файл.Расширение, Файл.АдресДанных));
		АдресФайлаОбменаВоВременномХранилище = МассивФайлов[0].АдресДанных;
		Если ЗагрузитьФайлНаСервере(АдресФайлаОбменаВоВременномХранилище) Тогда
			Возврат;
		Иначе
			Закрыть();
		КонецЕсли;
		
	КонецЕсли;
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлИлиЗакрытьЗавершениеПредупреждениеЗавершение(ДополнительныеПараметры) Экспорт
	
	Закрыть();	
	
КонецПроцедуры

&НаСервере
Функция ЗагрузитьФайлНаСервере(АдресФайлаОбменаВоВременномХранилище)
	
	ПолноеИмяФайлаОбменаНаСервере = ПолучитьИмяВременногоФайла();
	ПолучитьИзВременногоХранилища(АдресФайлаОбменаВоВременномХранилище).Записать(ПолноеИмяФайлаОбменаНаСервере);
	
	// распаковываем файл описания из архива обмена
	ИмяФайлаОписания = "Описание.xml";
	ЧтениеЗИП = Новый ЧтениеZipФайла(ПолноеИмяФайлаОбменаНаСервере);
	ЭлементОписание = ЧтениеЗИП.Элементы.Найти(ИмяФайлаОписания);
	Если ЭлементОписание = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО();
	
	КаталогРаспаковки = КонтекстЭДОСервер.СоздатьВременныйКаталогСервер();
	ЧтениеЗИП.Извлечь(ЭлементОписание, КаталогРаспаковки, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	
	// читаем XML
	ТекстXML = КонтекстЭДОСервер.ПрочитатьТекстИзФайла(КаталогРаспаковки + ИмяФайлаОписания, , Истина);
	Если НЕ ЗначениеЗаполнено(ТекстXML) Тогда
		ЧтениеЗИП.Закрыть();
		КонтекстЭДОСервер.УдалитьВременныйФайл(ПолноеИмяФайлаОбменаНаСервере);
		КонтекстЭДОСервер.УдалитьВременныйФайл(КаталогРаспаковки);
		Возврат Ложь;
	КонецЕсли;
	
	// загружаем XML в дерево
	ДеревоXML = КонтекстЭДОСервер.ЗагрузитьСтрокуXMLВДеревоЗначений(ТекстXML);
	Если НЕ ЗначениеЗаполнено(ДеревоXML) Тогда
		ЧтениеЗИП.Закрыть();
		КонтекстЭДОСервер.УдалитьВременныйФайл(ПолноеИмяФайлаОбменаНаСервере);
		КонтекстЭДОСервер.УдалитьВременныйФайл(КаталогРаспаковки);
		Возврат Ложь;
	КонецЕсли;
	
	// разбираем дерево XML, заполняем таблицу ЗагруженныеДокументы
	Если НЕ ЗаполнитьТаблицуЗагруженныеДокументы(ДеревоXML) Тогда
		Возврат Ложь;	
	КонецЕсли;
	
	//заполняем таблицу ОтображаемыеДокументы
	ЗаполнитьПоОтборамТаблицуОтображаемыеДокументы();
	
	Возврат Истина;
	
КонецФункции

&НаСервере
Функция ЗаполнитьТаблицуЗагруженныеДокументы(ДеревоXML)
	
	УзелФайл = ДеревоXML.Строки.Найти("Файл", "Имя");
	Если НЕ ЗначениеЗаполнено(УзелФайл) Тогда
		Сообщить("Некорректная структура XML файла описания.", СтатусСообщения.Важное);
		Возврат Ложь;
	КонецЕсли;
	
	УзелВерсФорм 		= УзелФайл.Строки.Найти("ВерсФорм", 		"Имя");
	УзелДатаВыгрузки 	= УзелФайл.Строки.Найти("ДатаВыгрузки", 	"Имя");
	УзелВремяВыгрузки 	= УзелФайл.Строки.Найти("ВремяВыгрузки", 	"Имя");
	
	УзелОрганизация 	= УзелФайл.Строки.Найти("Организация", 		"Имя");
	УзелКонтрагенты 	= УзелФайл.Строки.Найти("Контрагенты", 		"Имя");
	
	УзлыДокумент = УзелФайл.Строки.НайтиСтроки(Новый Структура("Имя", "Документ"));
	
	Если НЕ ЗначениеЗаполнено(УзелВерсФорм) 
		ИЛИ НЕ ЗначениеЗаполнено(УзелДатаВыгрузки) 
		ИЛИ НЕ ЗначениеЗаполнено(УзелВремяВыгрузки) 
		ИЛИ НЕ ЗначениеЗаполнено(УзелОрганизация) 
		ИЛИ НЕ ЗначениеЗаполнено(УзелКонтрагенты) 
		ИЛИ НЕ ЗначениеЗаполнено(УзлыДокумент) Тогда
		
		Сообщить("Некорректная структура XML файла описания.", СтатусСообщения.Важное);
		Возврат Ложь;
		
	КонецЕсли;
	
	УзелНаименование 	= УзелОрганизация.Строки.Найти("Наименование", 		"Имя");
	УзелИНН			 	= УзелОрганизация.Строки.Найти("ИНН", 				"Имя");
	УзелКПП 			= УзелОрганизация.Строки.Найти("КПП", 				"Имя");
	
	Если НЕ ЗначениеЗаполнено(УзелНаименование) 
		ИЛИ НЕ ЗначениеЗаполнено(УзелИНН)Тогда
		
		Сообщить("Некорректная структура XML файла описания.", СтатусСообщения.Важное);
		Возврат Ложь;
		
	КонецЕсли;
	
	ПредставлениеОрганизация = УзелНаименование.Значение + " " 
		+ УзелИНН.Значение 
		+ ?(ЗначениеЗаполнено(УзелКПП), "/" + УзелКПП.Значение, "");
		
	ПредставлениеДатаВремяВыгрузки = УзелДатаВыгрузки.Значение + " " + СтрЗаменить(УзелВремяВыгрузки.Значение, ".", ":");
	
	СоответствиеКонтрагентов = Новый Соответствие;
	СписокВыбораКонтрагентов = Элементы.Контрагент.СписокВыбора;
	СписокВыбораКонтрагентов.Очистить();
	
	Для каждого УзелКонтрагент Из УзелКонтрагенты.Строки Цикл
		УзелНаименование 	= УзелКонтрагент.Строки.Найти("Наименование",	"Имя");	
		УзелИНН			 	= УзелКонтрагент.Строки.Найти("ИНН", 			"Имя");
		УзелКПП 			= УзелКонтрагент.Строки.Найти("КПП", 			"Имя");
		УзелИдентификатор	= УзелКонтрагент.Строки.Найти("Идентификатор", 	"Имя");
		
		Если НЕ ЗначениеЗаполнено(УзелНаименование) 
			ИЛИ НЕ ЗначениеЗаполнено(УзелИНН)
			ИЛИ НЕ ЗначениеЗаполнено(УзелИдентификатор) Тогда
			
			Сообщить("Некорректная структура XML файла описания.", СтатусСообщения.Важное);
			Возврат Ложь;
			
		КонецЕсли;
		
		ПредставлениеКонтрагента = УзелНаименование.Значение + " " 
			+ УзелИНН.Значение 
			+ ?(ЗначениеЗаполнено(УзелКПП), "/" + УзелКПП.Значение, "");
		
		СоответствиеКонтрагентов.Вставить(УзелИдентификатор.Значение, ПредставлениеКонтрагента);
		СписокВыбораКонтрагентов.Добавить(ПредставлениеКонтрагента);
		
	КонецЦикла;
	
	ЗагруженныеДокументы.Очистить();
	
	СоответствиеВидовДокументов = Новый Соответствие;
	
	СоответствиеВидовДокументов.Вставить("01", Перечисления.ВидыПредставляемыхДокументов.СчетФактура);
	СоответствиеВидовДокументов.Вставить("02", Перечисления.ВидыПредставляемыхДокументов.АктПриемкиСдачиРабот);
	СоответствиеВидовДокументов.Вставить("03", Перечисления.ВидыПредставляемыхДокументов.ТоварнаяНакладнаяТОРГ12);
	СоответствиеВидовДокументов.Вставить("04", Перечисления.ВидыПредставляемыхДокументов.КорректировочныйСчетФактура);
	
	СоответствиеНаправлений = Новый Соответствие;
	
	СоответствиеНаправлений.Вставить("0", "Входящий");
	СоответствиеНаправлений.Вставить("1", "Исходящий");
	
	Для каждого УзелДокумент Из УзлыДокумент Цикл
		УзелВид				= УзелДокумент.Строки.Найти("Вид",				"Имя");	
		УзелКНД				= УзелДокумент.Строки.Найти("КНД",				"Имя");
		УзелНаправление		= УзелДокумент.Строки.Найти("Направление",		"Имя");
		УзелНомер			= УзелДокумент.Строки.Найти("Номер",			"Имя");
		УзелДата			= УзелДокумент.Строки.Найти("Дата",				"Имя");
		УзелНомерДокОсн		= УзелДокумент.Строки.Найти("НомерДокОсн",		"Имя");
		УзелДатаДокОсн		= УзелДокумент.Строки.Найти("ДатаДокОсн",		"Имя");
		УзелИдКонтрагента	= УзелДокумент.Строки.Найти("ИдКонтрагента",	"Имя");
		УзелФайлДок			= УзелДокумент.Строки.Найти("ФайлДок",			"Имя");
		УзелФайлЭЦП			= УзелДокумент.Строки.Найти("ФайлЭЦП",			"Имя");
		
		
		Если НЕ ЗначениеЗаполнено(УзелВид) 
			ИЛИ НЕ ЗначениеЗаполнено(УзелКНД)
			ИЛИ НЕ ЗначениеЗаполнено(УзелНаправление)
			ИЛИ НЕ ЗначениеЗаполнено(УзелНомер)
			ИЛИ НЕ ЗначениеЗаполнено(УзелДата)
			ИЛИ НЕ ЗначениеЗаполнено(УзелИдКонтрагента)
			ИЛИ НЕ ЗначениеЗаполнено(УзелФайлДок)
			ИЛИ НЕ ЗначениеЗаполнено(УзелФайлЭЦП) Тогда
			
			Сообщить("Некорректная структура XML файла описания.", СтатусСообщения.Важное);
			Возврат Ложь;
			
		КонецЕсли;
		
		УзелФайлДокИмя		= УзелФайлДок.Строки.Найти("Имя", 		"Имя");
		УзелФайлДокРазмер	= УзелФайлДок.Строки.Найти("Размер", 	"Имя");
		
		УзелФайлЭЦПИмя		= УзелФайлЭЦП.Строки.Найти("Имя", 		"Имя");
		УзелФайлЭЦПРазмер	= УзелФайлЭЦП.Строки.Найти("Размер", 	"Имя");
		
		Если НЕ ЗначениеЗаполнено(УзелФайлДокИмя) 
			ИЛИ НЕ ЗначениеЗаполнено(УзелФайлДокРазмер)
			ИЛИ НЕ ЗначениеЗаполнено(УзелФайлЭЦПИмя)
			ИЛИ НЕ ЗначениеЗаполнено(УзелФайлЭЦПРазмер) Тогда
			
			Сообщить("Некорректная структура XML файла описания.", СтатусСообщения.Важное);
			Возврат Ложь;
			
		КонецЕсли;
		
		//добавляем новую строку таблицы ЗагруженныеДокументы и заполняем её
		НоваяСтрока = ЗагруженныеДокументы.Добавить();
		
		НоваяСтрока.ВидДокумента 		= СоответствиеВидовДокументов[УзелВид.Значение];
		НоваяСтрока.КНД 				= УзелКНД.Значение;
		НоваяСтрока.Направление 		= СоответствиеНаправлений[УзелНаправление.Значение];
		НоваяСтрока.Номер 				= УзелНомер.Значение;
		НоваяСтрока.Дата 				= ДатаИзСтроки(УзелДата.Значение);
		НоваяСтрока.НомерДокОсн 		= ?(ЗначениеЗаполнено(УзелНомерДокОсн), УзелНомерДокОсн.Значение, "");
		НоваяСтрока.ДатаДокОсн 			= ?(ЗначениеЗаполнено(УзелНомерДокОсн), ДатаИзСтроки(УзелДатаДокОсн.Значение), "");
		НоваяСтрока.Контрагент 			= СоответствиеКонтрагентов[УзелИдКонтрагента.Значение];
		НоваяСтрока.ФайлВыгрузкиИмя 	= УзелФайлДокИмя.Значение;
		НоваяСтрока.ФайлВыгрузкиРазмер 	= XMLЗначение(Тип("Число"),УзелФайлДокРазмер.Значение);
		НоваяСтрока.ФайлПодписиИмя 		= УзелФайлЭЦПИмя.Значение;
		НоваяСтрока.ФайлПодписиРазмер 	= XMLЗначение(Тип("Число"),УзелФайлЭЦПРазмер.Значение);
		
		НоваяСтрока.ПредставлениеДокумента = Строка(НоваяСтрока.ВидДокумента) + " N" + НоваяСтрока.Номер + " от " + Формат(НоваяСтрока.Дата, "ДЛФ=D");
		Если ЗначениеЗаполнено(НоваяСтрока.НомерДокОсн) ИЛИ ЗначениеЗаполнено(НоваяСтрока.ДатаДокОсн) Тогда
			НоваяСтрока.ПредставлениеОснования = "Договор N" + НоваяСтрока.НомерДокОсн + " от " + Формат(НоваяСтрока.ДатаДокОсн, "ДЛФ=D");
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

&НаСервереБезКонтекста
Функция ДатаИзСтроки(СтрДата)
	Если СтрДата = "" Тогда
		ВозвращаемаяДата = Дата(1, 1, 1);
	Иначе
		МассивПодстрок = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(СтрДата, ".");
		Если Число(МассивПодстрок[0]) = 0 Тогда
			МассивПодстрок[0] = "1";
		КонецЕсли;
		Если Число(МассивПодстрок[1]) = 0 Тогда
			МассивПодстрок[1] = "1";
		КонецЕсли;
		Если Число(МассивПодстрок[2]) = 0 Тогда
			МассивПодстрок[2] = "1";
		КонецЕсли;
		ВозвращаемаяДата = Дата(МассивПодстрок[2], МассивПодстрок[1], МассивПодстрок[0]);
	КонецЕсли;
	
	Возврат ВозвращаемаяДата;
	
КонецФункции

&НаСервере
Функция ЗаполнитьПоОтборамТаблицуОтображаемыеДокументы()
	
	ПараметрыОтбора = Новый Структура;
	Если ЗначениеЗаполнено(ВидДокумента) Тогда
		ПараметрыОтбора.Вставить("ВидДокумента", ВидДокумента);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Направление) Тогда
		ПараметрыОтбора.Вставить("Направление", Направление);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Контрагент) Тогда
		ПараметрыОтбора.Вставить("Контрагент", Контрагент);
	КонецЕсли;
	
	Если ПараметрыОтбора.Количество() = 0 Тогда
		ОтобранныеСтроки = ЗагруженныеДокументы;	// ОтобранныеСтроки - ТЗ
	Иначе
		ОтобранныеСтроки = ЗагруженныеДокументы.НайтиСтроки(ПараметрыОтбора); // ОтобранныеСтроки - массив строк ТЗ
	КонецЕсли;
	
	ОтображаемыеДокументы.Очистить();
	
	Для каждого ОтобраннаяСтрока Из ОтобранныеСтроки Цикл
		НоваяСтрока = ОтображаемыеДокументы.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ОтобраннаяСтрока); 
	КонецЦикла;
		
КонецФункции

&НаСервере
Функция ПоместитьВХранилищеТаблицуВыбранныхДокументов()
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("Выбрать", Истина);
	
	ВыбранныеСтроки = ОтображаемыеДокументы.НайтиСтроки(ПараметрыОтбора);
	
	ТЗОтображаемыеДокументы = ДанныеФормыВЗначение(ОтображаемыеДокументы, Тип("ТаблицаЗначений"));
	ВыбранныеДокументы = ТЗОтображаемыеДокументы.Скопировать(Новый Массив);
	
	Для каждого ВыбраннаяСтрока Из ВыбранныеСтроки Цикл
		НоваяСтрока = ВыбранныеДокументы.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ВыбраннаяСтрока); 
	КонецЦикла;
	
 	Возврат ПоместитьВоВременноеХранилище(ВыбранныеДокументы, ИдентификаторФормыВладельца);
		
КонецФункции


	
