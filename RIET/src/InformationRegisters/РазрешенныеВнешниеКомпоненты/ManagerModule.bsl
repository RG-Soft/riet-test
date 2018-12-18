#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Возвращает XDTO-тип, описывающий разрешения типа, соответствующего элементу кэша.
//
// Возвращаемое значение - ТипОбъектаXDTO.
//
Функция ТипXDTOПредставленияРазрешений() Экспорт
	
	Возврат ФабрикаXDTO.Тип(РаботаВБезопасномРежимеСлужебный.ПакетXDTOПредставленийРазрешений(), "AttachAddin");
	
КонецФункции

// Формирует набор записей текущего регистра кэша из XDTO-представлений разрешения.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка,
//  Владелец - ЛюбаяСсылка,
//  XDTOПредставления - Массив(ОбъектXDTO).
//
// Возвращаемое значение - РегистрСведенийНаборЗаписей.
//
Функция НаборЗаписейИзXDTOПредставления(Знач XDTOПредставления, Знач ВнешнийМодуль, Знач Владелец, Знач ДляУдаления) Экспорт
	
	Набор = СоздатьНаборЗаписей();
	
	СвойстваПрограммногоМодуля = Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.СвойстваДляРегистраРазрешений(ВнешнийМодуль);
	Набор.Отбор.ТипПрограммногоМодуля.Установить(СвойстваПрограммногоМодуля.Тип);
	Набор.Отбор.ИдентификаторПрограммногоМодуля.Установить(СвойстваПрограммногоМодуля.Идентификатор);
	
	СвойстваВладельца = Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.СвойстваДляРегистраРазрешений(Владелец);
	Набор.Отбор.ТипВладельца.Установить(СвойстваВладельца.Тип);
	Набор.Отбор.ИдентификаторВладельца.Установить(СвойстваВладельца.Идентификатор);
	
	Если ДляУдаления Тогда
		
		Возврат Набор;
		
	Иначе
		
		Таблица = Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.ТаблицаРазрешений(СоздатьНаборЗаписей().Метаданные(), Истина);
		
		Для Каждого XDTOПредставление Из XDTOПредставления Цикл
			
			Ключ = Новый Структура("ТипПрограммногоМодуля,ИдентификаторПрограммногоМодуля,ТипВладельца,ИдентификаторВладельца,ИмяМакета",
				СвойстваПрограммногоМодуля.Тип,
				СвойстваПрограммногоМодуля.Идентификатор,
				СвойстваВладельца.Тип,
				СвойстваВладельца.Идентификатор,
				XDTOПредставление.TemplateName);
			Если Таблица.НайтиСтроки(Ключ).Количество() = 0 Тогда
				
				СтруктураИмени = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(XDTOПредставление.TemplateName, ".");
				
				Если СтруктураИмени.Количество() = 2 Тогда
					
					// Это общий макет
					Макет = ПолучитьОбщийМакет(СтруктураИмени[1]);
					
				ИначеЕсли СтруктураИмени.Количество() = 4 Тогда
					
					// Это макет объекта метаданных
					МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(СтруктураИмени[0] + "." + СтруктураИмени[1]);
					Макет = МенеджерОбъекта.ПолучитьМакет(СтруктураИмени[3]);
					
				Иначе
					ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						ВернутьСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты:
							  |некорректное имя макета %1!'"), XDTOПредставление.TemplateName);
				КонецЕсли;
				
				Если Макет = Неопределено Тогда
					ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						ВернутьСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты,
							  |поставляемой в макете %1: макет %1 не обнаружден в составе конфигурации!'"), XDTOПредставление.TemplateName);
				КонецЕсли;
				
				Если Метаданные.НайтиПоПолномуИмени(XDTOПредставление.TemplateName).ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ДвоичныеДанные Тогда
					ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						ВернутьСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты:
							  |макет %1 не содержит двоичных данных!'"), XDTOПредставление.TemplateName);
				КонецЕсли;
				
				ВременныйФайл = ПолучитьИмяВременногоФайла("zip");
				Макет.Записать(ВременныйФайл);
				
				Архиватор = Новый ЧтениеZipФайла(ВременныйФайл);
				КаталогРаспаковки = ПолучитьИмяВременногоФайла() + "\";
				СоздатьКаталог(КаталогРаспаковки);
				
				ФайлМанифеста = "";
				Для Каждого ЭлементАрхива Из Архиватор.Элементы Цикл
					Если ВРег(ЭлементАрхива.Имя) = "MANIFEST.XML" Тогда
						ФайлМанифеста = КаталогРаспаковки + ЭлементАрхива.Имя;
						Архиватор.Извлечь(ЭлементАрхива, КаталогРаспаковки);
					КонецЕсли;
				КонецЦикла;
				
				Если ПустаяСтрока(ФайлМанифеста) Тогда
					ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						ВернутьСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты,
							  |поставляемой в макете %1: в архиве не обнаружен файл MANIFEST.XML!'"), XDTOПредставление.TemplateName);
				КонецЕсли;
				
				ПотокЧтения = Новый ЧтениеXML();
				ПотокЧтения.ОткрытьФайл(ФайлМанифеста);
				ОписаниеКомплекта = ФабрикаXDTO.ПрочитатьXML(ПотокЧтения, ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/addin/bundle", "bundle"));
				Для Каждого ОписаниеКомпоненты Из ОписаниеКомплекта.component Цикл
					
					Если ОписаниеКомпоненты.type = "native" ИЛИ ОписаниеКомпоненты.type = "com" Тогда
						
						ФайлКомпоненты = КаталогРаспаковки + ОписаниеКомпоненты.path;
						
						Архиватор.Извлечь(Архиватор.Элементы.Найти(ОписаниеКомпоненты.path), КаталогРаспаковки);
						
						Хэширование = Новый ХешированиеДанных(ХешФункция.SHA1);
						Хэширование.ДобавитьФайл(ФайлКомпоненты);
						
						ХэшСумма = Хэширование.ХешСумма;
						ХэшСуммаПреобразованнаяКСтрокеBase64 = Base64Строка(ХэшСумма);
						
						Строка = Таблица.Добавить();
						Строка.ТипПрограммногоМодуля = СвойстваПрограммногоМодуля.Тип;
						Строка.ИдентификаторПрограммногоМодуля = СвойстваПрограммногоМодуля.Идентификатор;
						Строка.ТипВладельца = СвойстваВладельца.Тип;
						Строка.ИдентификаторВладельца = СвойстваВладельца.Идентификатор;
						Строка.ИмяМакета = XDTOПредставление.TemplateName;
						Строка.ИмяФайла = ОписаниеКомпоненты.path;
						Строка.ХэшСумма = ХэшСуммаПреобразованнаяКСтрокеBase64;
						
					КонецЕсли;
					
				КонецЦикла;
				
				ПотокЧтения.Закрыть();
				Архиватор.Закрыть();
				
				Попытка
					УдалитьФайлы(КаталогРаспаковки);
				Исключение
					// Обработка исключения не требуется
				КонецПопытки;
				
				Попытка
					УдалитьФайлы(ВременныйФайл);
				Исключение
					// Обработка исключения не требуется
				КонецПопытки;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Набор.Загрузить(Таблица);
		Возврат Набор;
		
	КонецЕсли;
	
КонецФункции

// Заполняет описание профиля безопасности (в нотации программного интерфейса общего модуля
//  АдминистрированиеКластераКлиентСервер) по менеджеру записи текущего элемента кэша.
//
// Параметры:
//  Менеджер - РегистрСведенийМенеджерЗаписи,
//  Профиль - Структура.
//
Процедура ЗаполнитьСвойстваПрофиляБезопасностиВНотацииИнтерфейсаАдминистрирования(Знач Менеджер, Профиль) Экспорт
	
	ВнешнийКомпонент = АдминистрированиеКластераКлиентСервер.СвойстваВнешнейКомпоненты();
	ВнешнийКомпонент.Имя = Менеджер.ИмяМакета + "\" + Менеджер.ИмяФайла;
	ВнешнийКомпонент.ХэшСумма = Менеджер.ХэшСумма;
	Профиль.ВнешниеКомпоненты.Добавить(ВнешнийКомпонент);
	
КонецПроцедуры

// Возвращает текст запроса для получения текущего среза разрешений по данному
//  элементу кэша.
//
// Параметры:
//  СвернутьВладельцев - Булево - флаг необходимости сворачивания результата запроса
//    по владельцам.
//
// Возвращаемое значение - Строка, текст запроса.
//
Функция ЗапросТекущегоСреза(Знач СвернутьВладельцев = Истина) Экспорт
	
	Если СвернутьВладельцев Тогда
		
		Возврат "ВЫБРАТЬ РАЗЛИЧНЫЕ
		        |	Разрешения.ИмяМакета,
		        |	Разрешения.ИмяФайла,
		        |	Разрешения.ХэшСумма,
		        |	Разрешения.ТипПрограммногоМодуля КАК ТипПрограммногоМодуля,
		        |	Разрешения.ИдентификаторПрограммногоМодуля КАК ИдентификаторПрограммногоМодуля
		        |ИЗ
		        |	РегистрСведений.РазрешенныеВнешниеКомпоненты КАК Разрешения";
		
	Иначе
		
		Возврат "ВЫБРАТЬ РАЗЛИЧНЫЕ
		        |	Разрешения.ИмяМакета,
		        |	Разрешения.ИмяФайла,
		        |	Разрешения.ХэшСумма,
		        |	Разрешения.ТипПрограммногоМодуля КАК ТипПрограммногоМодуля,
		        |	Разрешения.ИдентификаторПрограммногоМодуля КАК ИдентификаторПрограммногоМодуля,
		        |	Разрешения.ТипВладельца КАК ТипВладельца,
		        |	Разрешения.ИдентификаторВладельца КАК ИдентификаторВладельца
		        |ИЗ
		        |	РегистрСведений.РазрешенныеВнешниеКомпоненты КАК Разрешения";
		
	КонецЕсли;
	
КонецФункции

// Возвращает текст запроса для получения дельты измения разрешений по данному
//  элементу кэша.
//
// Возвращаемое значение - Строка, текст запроса.
//
Функция ЗапросПолученияДельты() Экспорт
	
	Возврат
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВТ_До.ИмяМакета,
		|	ВТ_До.ИмяФайла,
		|	ВТ_До.ХэшСумма,
		|	ВТ_До.ТипПрограммногоМодуля,
		|	ВТ_До.ИдентификаторПрограммногоМодуля
		|ИЗ
		|	ВТ_До КАК ВТ_До
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_После КАК ВТ_После
		|		ПО ВТ_До.ТипПрограммногоМодуля = ВТ_После.ТипПрограммногоМодуля
		|			И ВТ_До.ИдентификаторПрограммногоМодуля = ВТ_После.ИдентификаторПрограммногоМодуля
		|			И ВТ_До.ИмяМакета = ВТ_После.ИмяМакета
		|ГДЕ
		|	ВТ_После.ИмяМакета ЕСТЬ NULL 
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВТ_После.ИмяМакета,
		|	ВТ_После.ИмяФайла,
		|	ВТ_После.ХэшСумма,
		|	ВТ_После.ТипПрограммногоМодуля,
		|	ВТ_После.ИдентификаторПрограммногоМодуля
		|ИЗ
		|	ВТ_После КАК ВТ_После
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_До КАК ВТ_До
		|		ПО ВТ_После.ТипПрограммногоМодуля = ВТ_До.ТипПрограммногоМодуля
		|			И ВТ_После.ИдентификаторПрограммногоМодуля = ВТ_До.ИдентификаторПрограммногоМодуля
		|			И ВТ_После.ИмяМакета = ВТ_До.ИмяМакета
		|ГДЕ
		|	ВТ_До.ИмяМакета ЕСТЬ NULL ";
	
КонецФункции

#КонецОбласти

#КонецЕсли