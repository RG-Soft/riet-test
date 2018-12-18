////////////////////////////////////////////////////////////////////////////////
// Подсистема "Базовая функциональность".
// Серверные процедуры и функции общего назначения.
//  
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возвращает признак наличия в конфигурации общих реквизитов-разделителей.
//
// Возвращаемое значение:
// Булево.
//
Функция ЭтоРазделеннаяКонфигурация() Экспорт
	
	ЕстьРазделители = Ложь;
	Для каждого ОбщийРеквизит Из Метаданные.ОбщиеРеквизиты Цикл
		Если ОбщийРеквизит.РазделениеДанных = Метаданные.СвойстваОбъектов.РазделениеДанныхОбщегоРеквизита.Разделять Тогда
			ЕстьРазделители = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ЕстьРазделители;
	
КонецФункции

// Возвращает массив существующих в конфигурации разделителей.
//
// Возвращаемое значение: ФиксированныйМассив(Строка) - массив имен общих реквизитов, которые
//  являются разделителями.
//
Функция РазделителиКонфигурации() Экспорт
	
	МассивРазделителей = Новый Массив;
	
	Для Каждого ОбщийРеквизит Из Метаданные.ОбщиеРеквизиты Цикл
		Если ОбщийРеквизит.РазделениеДанных = Метаданные.СвойстваОбъектов.РазделениеДанныхОбщегоРеквизита.Разделять Тогда
			МассивРазделителей.Добавить(ОбщийРеквизит.Имя);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Новый ФиксированныйМассив(МассивРазделителей);
	
КонецФункции

// Возвращает состав общего реквизита с заданным именем.
//
// Параметры:
// Имя - Строка - Имя общего реквизита.
//
// Возвращаемое значение:
// СоставОбщегоРеквизита.
//
Функция СоставОбщегоРеквизита(Знач Имя) Экспорт
	
	Возврат Метаданные.ОбщиеРеквизиты[Имя].Состав;
	
КонецФункции

// Возвращает признак того, что объект метаданных используется в общих реквизитах-разделителях.
//
// Параметры:
// ИмяОбъектаМетаданных - Строка.
// Разделитель - имя общего реквизита-разделителя, на разделение которыми проверяется объект метаданных.
//
// Возвращаемое значение:
// Булево.
//
Функция ЭтоРазделенныйОбъектМетаданных(Знач ИмяОбъектаМетаданных, Знач Разделитель) Экспорт
	
	Возврат ОбщегоНазначения.ЭтоРазделенныйОбъектМетаданных(ИмяОбъектаМетаданных, Разделитель);
	
КонецФункции

// Возвращает имя общего реквизита, который является разделителем основных данных.
//
// Возвращаемое значение: Строка.
//
Функция РазделительОсновныхДанных() Экспорт
	
	Результат = "";
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.БазоваяФункциональностьВМоделиСервиса") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		Результат = МодульРаботаВМоделиСервиса.РазделительОсновныхДанных();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает имя общего реквизита, который является разделителем вспомогательных данных.
//
// Возвращаемое значение: Строка.
//
Функция РазделительВспомогательныхДанных() Экспорт
	
	Результат = "";
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.БазоваяФункциональностьВМоделиСервиса") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		Результат = МодульРаботаВМоделиСервиса.РазделительВспомогательныхДанных();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает признак включения условного разделения.
// В случае вызова в неразделенной конфигурации возвращает Ложь.
//
Функция РазделениеВключено() Экспорт
	
	Возврат ОбщегоНазначенияПовтИсп.ЭтоРазделеннаяКонфигурация() И ПолучитьФункциональнуюОпцию("РаботаВМоделиСервиса");
	
КонецФункции

// Возвращает признак возможности обращения к разделенным данным из текущего сеанса.
// В случае вызова в неразделенной конфигурации возвращает Истина.
//
// Возвращаемое значение:
// Булево.
//
Функция ДоступноИспользованиеРазделенныхДанных() Экспорт
	
	Возврат НЕ ОбщегоНазначенияПовтИсп.РазделениеВключено() ИЛИ ОбщегоНазначения.ИспользованиеРазделителяСеанса();
	
КонецФункции

// Возвращает объект ПреобразованиеXSL созданный из общего макета с переданным
// именем.
//
// Параметры:
// ИмяОбщегоМакет - Строка - имя общего макета типа ДвоичныеДанные содержащего
// файл преобразования XSL.
//
// Возвращаемое значение:
// ПреобразованиеXSL - объект ПреобразованиеXSL.
//
Функция ПолучитьПреобразованиеXSLИзОбщегоМакета(Знач ИмяОбщегоМакета) Экспорт
	
	ДанныеМакета = ПолучитьОбщийМакет(ИмяОбщегоМакета);
	ИмяФайлаПреобразования = ПолучитьИмяВременногоФайла("xsl");
	ДанныеМакета.Записать(ИмяФайлаПреобразования);
	
	Преобразование = Новый ПреобразованиеXSL;
	Преобразование.ЗагрузитьИзФайла(ИмяФайлаПреобразования);
	
	Попытка
		УдалитьФайлы(ИмяФайлаПреобразования);
	Исключение
		ЗаписьЖурналаРегистрации(ВернутьСтр("ru = 'Получение XSL'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат Преобразование;
	
КонецФункции

// Определяет, сеанс запущен с разделителями или без.
//
// Возвращаемое значение:
// Булево.
//
Функция СеансЗапущенБезРазделителей() Экспорт
	
	Возврат ПользователиИнформационнойБазы.ТекущийПользователь().РазделениеДанных.Количество() = 0;
	
КонецФункции

// Возвращает тип платформы сервера.
//
// Возвращаемое значение:
//   ТипПлатформы; Неопределено.
//
Функция ТипПлатформыСервера() Экспорт
	
	ТипПлатформыСервераСтрокой = СтандартныеПодсистемыВызовСервера.ТипПлатформыСервераСтрокой();
	
	Если ТипПлатформыСервераСтрокой = "Linux_x86" Тогда
		Возврат ТипПлатформы.Linux_x86;
		
	ИначеЕсли ТипПлатформыСервераСтрокой = "Linux_x86_64" Тогда
		Возврат ТипПлатформы.Linux_x86_64;
		
	ИначеЕсли ТипПлатформыСервераСтрокой = "Windows_x86" Тогда
		Возврат ТипПлатформы.Windows_x86;
		
	ИначеЕсли ТипПлатформыСервераСтрокой = "Windows_x86_64" Тогда
		Возврат ТипПлатформы.Windows_x86_64;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

// Определяет текущий режим работы программы.
//   В частности используется в панелях настроек программы
//   для скрытия специализированных интерфейсов, предназначенных не для всех режимов работы.
//
// Возвращаемое значение:
//   Структура - Настройки, описывающие права текущего пользователя и текущий режим работы программы.
//     По правам:
//       * ЭтоАдминистраторСистемы   - Булево - Истина, если есть право администрирования информационной базы.
//       * ЭтоАдминистраторПрограммы - Булево - Истина, если есть доступ ко всем "прикладным" данным информационной
//                                              базы.
//     По режимам работы базы:
//       * МодельСервиса   - Булево - Истина, если в конфигурации есть разделители и они условно включены.
//       * Локальный       - Булево - Истина, если конфигурации работает в обычном режиме (не в модели сервиса и не в
//                                    автономном рабочем месте).
//       * Автономный      - Булево - Истина, если конфигурации работает в режиме АРМ (автономное рабочее место).
//       * Файловый        - Булево - Истина, если конфигурации работает в файловом режиме.
//       * КлиентСерверный - Булево - Истина, если конфигурации работает в клиент-серверном режиме.
//       * ЛокальныйФайловый        - Булево - Истина, если работа в обычном файловом режиме.
//       * ЛокальныйКлиентСерверный - Булево - Истина, если работа в обычном клиент-серверном режиме.
//     По функциональности клиентской части:
//       * ЭтоLinuxКлиент - Булево - Истина, если клиентское приложение запущено под управлением ОС Linux.
//       * ЭтоВебКлиент   - Булево - Истина, если клиентское приложение является Веб-клиентом.
//
// Описание:
//   В панелях настроек программы включены 5 интерфейсов:
//     - Для администратора сервиса в области данных абонента (АС).
//     - Для администратора абонента (АА).
//     - Для администратора локального решения в клиент-серверном режиме (ЛКС).
//     - Для администратора локального решения в файловом режиме (ЛФ).
//     - Для администратора автономного рабочего места (АРМ).
//   
//   Интерфейсы АС и АА разрезаются при помощи скрытия групп и элементов формы
//     для всех ролей, кроме роли "АдминистраторСистемы".
//   
//   Администратор сервиса, выполнивший вход в область данных,
//     должен видеть те же настройки что и администратор абонента
//     вместе с настройками сервиса (неразделенными).
//
Функция РежимРаботыПрограммы() Экспорт
	РежимРаботы = Новый Структура;
	
	// Права текущего пользователя.
	РежимРаботы.Вставить("ЭтоАдминистраторПрограммы", Пользователи.ЭтоПолноправныйПользователь(, Ложь, Ложь)); // АА, АС, ЛКС, ЛФ
	РежимРаботы.Вставить("ЭтоАдминистраторСистемы",   Пользователи.ЭтоПолноправныйПользователь(, Истина, Ложь)); // АС, ЛКС, ЛФ
	
	// Режимы работы сервера.
	РежимРаботы.Вставить("МодельСервиса", РазделениеВключено()); // АС, АА
	РежимРаботы.Вставить("Локальный",     ПолучитьФункциональнуюОпцию("РаботаВЛокальномРежиме")); // ЛКС, ЛФ
	РежимРаботы.Вставить("Автономный",    ПолучитьФункциональнуюОпцию("РаботаВАвтономномРежиме")); // АРМ
	РежимРаботы.Вставить("Файловый",        Ложь); // АС, АА, ЛФ
	РежимРаботы.Вставить("КлиентСерверный", Ложь); // АС, АА, ЛКС
	
	Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		РежимРаботы.Файловый = Истина;
	Иначе
		РежимРаботы.КлиентСерверный = Истина;
	КонецЕсли;
	
	РежимРаботы.Вставить("ЛокальныйФайловый",
		РежимРаботы.Локальный И РежимРаботы.Файловый); // ЛФ
	РежимРаботы.Вставить("ЛокальныйКлиентСерверный",
		РежимРаботы.Локальный И РежимРаботы.КлиентСерверный); // ЛКС
	
	// Режимы работы клиента.
	РежимРаботы.Вставить("ЭтоLinuxКлиент", ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент());
	РежимРаботы.Вставить("ЭтоВебКлиент",   ОбщегоНазначенияКлиентСервер.ЭтоВебКлиент());
	
	Возврат РежимРаботы;
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Возвращает список полных имен всех объектов метаданных, использующихся в общем реквизите-разделителе,
//  имя которого передано в качестве значения параметра Разделитель, и значения свойств объекта метаданных,
//  которые могут потребоваться для дальнейшей его обработки в универсальных алгоритмах.
// Для последовательностей и журналов документов определяет разделенность по входящим документам: любому из.
//
// Параметры:
//  Разделитель - Строка, имя общего реквизита.
//
// Возвращаемое значение:
// ФиксированноеСоответствие,
//  Ключ - Строка, полное имя объекта метаданных,
//  Значение - ФиксированнаяСтруктура,
//    Имя - Строка, имя объекта метаданных,
//    Разделитель - Строка, имя разделителя, которым разделен объект метаданных,
//    УсловноеРазделение - Строка, полное имя объекта метаданных, выступающего в качестве условия использования
//      разделения объекта метаданных данным разделителем.
//
Функция РазделенныеОбъектыМетаданных(Знач Разделитель) Экспорт
	
	Результат = Новый Соответствие;
	
	// I. Перебрать состав всех общих реквизитов.
	
	МетаданныеОбщегоРеквизита = Метаданные.ОбщиеРеквизиты.Найти(Разделитель);
	Если МетаданныеОбщегоРеквизита = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'Общий реквизит %1 не обнаружен в конфигурации!'"), Разделитель);
	КонецЕсли;
	
	Если МетаданныеОбщегоРеквизита.РазделениеДанных = Метаданные.СвойстваОбъектов.РазделениеДанныхОбщегоРеквизита.Разделять Тогда
		
		СоставОбщегоРеквизита = ОбщегоНазначенияПовтИсп.СоставОбщегоРеквизита(МетаданныеОбщегоРеквизита.Имя);
		
		ИспользоватьОбщийРеквизит = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать;
		АвтоИспользоватьОбщийРеквизит = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Авто;
		АвтоИспользованиеОбщегоРеквизита = 
			(МетаданныеОбщегоРеквизита.АвтоИспользование = Метаданные.СвойстваОбъектов.АвтоИспользованиеОбщегоРеквизита.Использовать);
		
		Для Каждого ЭлементСостава Из СоставОбщегоРеквизита Цикл
			
			Если (АвтоИспользованиеОбщегоРеквизита И ЭлементСостава.Использование = АвтоИспользоватьОбщийРеквизит)
				ИЛИ ЭлементСостава.Использование = ИспользоватьОбщийРеквизит Тогда
				
				ДополнительныеДанные = Новый Структура("Имя,Разделитель,УсловноеРазделение", ЭлементСостава.Метаданные.Имя, Разделитель, Неопределено);
				Если ЭлементСостава.УсловноеРазделение <> Неопределено Тогда
					ДополнительныеДанные.УсловноеРазделение = ЭлементСостава.УсловноеРазделение.ПолноеИмя();
				КонецЕсли;
				
				Результат.Вставить(ЭлементСостава.Метаданные.ПолноеИмя(), Новый ФиксированнаяСтруктура(ДополнительныеДанные));
				
				// По регистрам расчета дополнительно определяется разделенность подчиненных им перерасчетов.
				Если ОбщегоНазначения.ЭтоРегистрРасчета(ЭлементСостава.Метаданные) Тогда
					
					Перерасчеты = ЭлементСостава.Метаданные.Перерасчеты;
					Для Каждого Перерасчет Из Перерасчеты Цикл
						
						ДополнительныеДанные.Имя = Перерасчет.Имя;
						Результат.Вставить(Перерасчет.ПолноеИмя(), Новый ФиксированнаяСтруктура(ДополнительныеДанные));
						
					КонецЦикла;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'Для общего реквизита %1 не используется разделение данных!'"), Разделитель);
		
	КонецЕсли;
	
	// II. Для последовательностей и журналов определять разделенность по входящим документам.
	
	// 1) Последовательности. Перебор с проверкой первого входящего документа. Если документов нет, считаем разделенной.
	Для Каждого МетаданныеПоследовательности Из Метаданные.Последовательности Цикл
		
		ДополнительныеДанные = Новый Структура("Имя,Разделитель,УсловноеРазделение", МетаданныеПоследовательности.Имя, Разделитель, Неопределено);
		
		Если МетаданныеПоследовательности.Документы.Количество() = 0 Тогда
			
			ШаблонСообщения = ВернутьСтр("ru = 'В последовательность %1 не включено ни одного документа.'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, МетаданныеПоследовательности.Имя);
			ЗаписьЖурналаРегистрации(ВернутьСтр("ru = 'Получение разделенных объектов метаданных'", 
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()), УровеньЖурналаРегистрации.Ошибка, 
				МетаданныеПоследовательности, , ТекстСообщения);
			
			Результат.Вставить(МетаданныеПоследовательности.ПолноеИмя(), Новый ФиксированнаяСтруктура(ДополнительныеДанные));
			
		Иначе
			
			Для Каждого МетаданныеДокумента Из МетаданныеПоследовательности.Документы Цикл
				
				ДополнительныеДанныеОтДокумента = Результат.Получить(МетаданныеДокумента.ПолноеИмя());
				
				Если ДополнительныеДанныеОтДокумента <> Неопределено Тогда
					ЗаполнитьЗначенияСвойств(ДополнительныеДанные, ДополнительныеДанныеОтДокумента, "Разделитель,УсловноеРазделение");
					Результат.Вставить(МетаданныеПоследовательности.ПолноеИмя(), Новый ФиксированнаяСтруктура(ДополнительныеДанные));
				КонецЕсли;
				
				Прервать;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	// 2) Журналы. Перебор с проверкой первого входящего документа. Если документов нет, считаем разделенным.
	Для Каждого МетаданныеЖурналаДокументов Из Метаданные.ЖурналыДокументов Цикл
		
		ДополнительныеДанные = Новый Структура("Имя,Разделитель,УсловноеРазделение", МетаданныеЖурналаДокументов.Имя, Разделитель, Неопределено);
		
		Если МетаданныеЖурналаДокументов.РегистрируемыеДокументы.Количество() = 0 Тогда
			
			ШаблонСообщения = ВернутьСтр("ru = 'В журнал %1 не включено ни одного документа.'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, МетаданныеЖурналаДокументов.Имя);
			ЗаписьЖурналаРегистрации(ВернутьСтр("ru = 'Получение разделенных объектов метаданных'", 
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()), УровеньЖурналаРегистрации.Ошибка, 
				МетаданныеЖурналаДокументов, , ТекстСообщения);
			
			Результат.Вставить(МетаданныеЖурналаДокументов.ПолноеИмя(), Новый ФиксированнаяСтруктура(ДополнительныеДанные));
			
		Иначе
			
			Для Каждого МетаданныеДокумента Из МетаданныеЖурналаДокументов.РегистрируемыеДокументы Цикл
				
				ДополнительныеДанныеОтДокумента = Результат.Получить(МетаданныеДокумента.ПолноеИмя());
				
				Если ДополнительныеДанныеОтДокумента <> Неопределено Тогда
					ЗаполнитьЗначенияСвойств(ДополнительныеДанные, ДополнительныеДанныеОтДокумента, "Разделитель,УсловноеРазделение");
					Результат.Вставить(МетаданныеЖурналаДокументов.ПолноеИмя(), Новый ФиксированнаяСтруктура(ДополнительныеДанные));
				КонецЕсли;
				
				Прервать;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Возвращает Истина, если программа работает в режиме автономного рабочего места.
Функция ЭтоАвтономноеРабочееМесто() Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	МодульОбменДаннымиПовтИсп = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиПовтИсп");
	
	Возврат МодульОбменДаннымиПовтИсп.ЭтоАвтономноеРабочееМесто();
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает данные кэша версий из ресурса типа ХранилищеЗначения регистра КэшПрограммныхИнтерфейсов.
//
// Параметры:
//   Идентификатор - Строка - идентификатор записи кэша.
//   ТипДанных     - ПеречислениеСсылка.ТипыДанныхКэшаПрограммныхИнтерфейсов.
//   ПараметрыПолучения - Строка - массив параметров сериализованный в XML для передачи в метод обновления кэша.
//   ВозвращатьУстаревшиеДанные - Булево - флаг определяющий необходимость ожидания обновления
//      данных в кэше перед возвратом значения, в случае обнаружения факта их устаревания.
//      Истина - всегда использовать данные из кэша, если они там есть. Ложь - ожидать
//      обновления данных кэша, в случае обнаружения факта устаревания данных.
//
// Возвращаемое значение:
//   Произвольный.
//
Функция ДанныеКэшаВерсий(Знач Идентификатор, Знач ТипДанных, Знач ПараметрыПолучения, Знач ИспользоватьУстаревшиеДанные = Истина) Экспорт
	
	ПараметрыПолучения = ОбщегоНазначения.ЗначениеИзСтрокиXML(ПараметрыПолучения);
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ТаблицаКэша.ДатаОбновления КАК ДатаОбновления,
		|	ТаблицаКэша.Данные КАК Данные,
		|	ТаблицаКэша.ТипДанных КАК ТипДанных
		|ИЗ
		|	РегистрСведений.КэшПрограммныхИнтерфейсов КАК ТаблицаКэша
		|ГДЕ
		|	ТаблицаКэша.Идентификатор = &Идентификатор
		|	И ТаблицаКэша.ТипДанных = &ТипДанных";
	Запрос.УстановитьПараметр("Идентификатор", Идентификатор);
	Запрос.УстановитьПараметр("ТипДанных", ТипДанных);
	
	НачатьТранзакцию();
	Попытка
		// Не устанавливаем управляемую блокировку, чтобы другие сеансы могли изменять значение пока эта транзакция активна.
		Результат = Запрос.Выполнить();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	ТребуетсяВыполнитьОбновление = Ложь;
	ТребуетсяПеречитатьДанные = Ложь;
	
	Если Результат.Пустой() Тогда
		
		ТребуетсяВыполнитьОбновление = Истина;
		ТребуетсяПеречитатьДанные = Истина;
		
	Иначе
		
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Если ОбщегоНазначения.ЗаписьКэшаВерсийУстарела(Выборка) Тогда
			ТребуетсяВыполнитьОбновление = Истина;
			ТребуетсяПеречитатьДанные = НЕ ИспользоватьУстаревшиеДанные;
		КонецЕсли;
	КонецЕсли;
	
	Если ТребуетсяВыполнитьОбновление Тогда
		
		ОбновлениеВТекущемСеансе = ТребуетсяПеречитатьДанные
			Или ОбщегоНазначения.ИнформационнаяБазаФайловая()
			Или МонопольныйРежим()
			Или ОбщегоНазначенияКлиентСервер.РежимОтладки()
			Или ТекущийРежимЗапуска() = Неопределено;
		
		Если ОбновлениеВТекущемСеансе Тогда
			ОбщегоНазначения.ОбновитьДанныеКэшаВерсий(Идентификатор, ТипДанных, ПараметрыПолучения);
			ТребуетсяПеречитатьДанные = Истина;
		Иначе
			ИмяМетодаЗадания = "ОбщегоНазначения.ОбновитьДанныеКэшаВерсий";
			НаименованиеЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'Обновление кэша версий. Идентификатор записи %1. Тип данных %2.'"),
				Идентификатор,
				ТипДанных);
			ПараметрыЗадания = Новый Массив;
			ПараметрыЗадания.Добавить(Идентификатор);
			ПараметрыЗадания.Добавить(ТипДанных);
			ПараметрыЗадания.Добавить(ПараметрыПолучения);
			
			ОтборЗаданий = Новый Структура;
			ОтборЗаданий.Вставить("ИмяМетода", ИмяМетодаЗадания);
			ОтборЗаданий.Вставить("Наименование", НаименованиеЗадания);
			ОтборЗаданий.Вставить("Состояние", СостояниеФоновогоЗадания.Активно);
			
			Задания = ФоновыеЗадания.ПолучитьФоновыеЗадания(ОтборЗаданий);
			Если Задания.Количество() = 0 Тогда
				// Запустим новое.
				ДлительныеОперации.ЗапуститьФоновоеЗаданиеСКонтекстомКлиента(ИмяМетодаЗадания,
					ПараметрыЗадания,, НаименованиеЗадания);
			КонецЕсли;
		КонецЕсли;
		
		Если ТребуетсяПеречитатьДанные Тогда
			
			НачатьТранзакцию();
			Попытка
				// Не устанавливаем управляемую блокировку что бы другие сеансы могли изменять значение пока эта транзакция активна.
				Результат = Запрос.Выполнить();
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				ВызватьИсключение;
			КонецПопытки;
			
			Если Результат.Пустой() Тогда
				ШаблонСообщения = ВернутьСтр("ru = 'Ошибка при обновлении кэша версий. Данные не получены.
					|Идентификатор записи: %1
					|Тип данных: %2'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, Идентификатор, ТипДанных);
					
				ВызватьИсключение(ТекстСообщения);
			КонецЕсли;
			
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
		КонецЕсли;
		
	КонецЕсли;
		
	Возврат Выборка.Данные.Получить();
	
КонецФункции
// Возвращает объект WSОпределения созданный с переданными параметрами.
//
// Параметры:
//  АдресWSDL - Строка - месторасположение wsdl.
//  ИмяПользователя - Строка - имя пользователя для входа на сервер.
//  Пароль - Строка - пароль пользователя.
//
// Примечание: при получении определения используется кэш, обновление которого осуществляется
//  при смене версии конфигурации. Если для целей отладки требуется обновить
//  значения в кэше, раньше этого времени, следует удалить из регистра сведений.
//  КэшПрограммныхИнтерфейсов соответствующие записи.
//
Функция WSОпределения(Знач АдресWSDL, Знач ИмяПользователя, Знач Пароль) Экспорт
	
	Возврат ОбщегоНазначения.WSОпределения(АдресWSDL, ИмяПользователя, Пароль);
	
КонецФункции

// Возвращает объект WSПрокси созданный с переданными параметрами.
//
// Параметры соответствуют конструктору объекта WSПрокси.
//
Функция WSПрокси(Знач АдресWSDL, Знач URIПространстваИмен, Знач ИмяСервиса,
	Знач ИмяТочкиПодключения, Знач ИмяПользователя, Знач Пароль, Знач Таймаут) Экспорт
	
	Возврат ОбщегоНазначения.ВнутренняяWSПрокси(АдресWSDL, URIПространстваИмен, ИмяСервиса, 
		ИмяТочкиПодключения, ИмяПользователя, Пароль, Таймаут);
	
КонецФункции

// Параметры, применяемых к элементам командного интерфейса, связанных с параметрическими функциональными опциями.
Функция ОпцииИнтерфейса() Экспорт
	
	ОпцииИнтерфейса = Новый Структура;
	Попытка
		ОбщегоНазначенияПереопределяемый.ПриОпределенииПараметровФункциональныхОпцийИнтерфейса(ОпцииИнтерфейса);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ИмяСобытия = ВернутьСтр("ru = 'Настройка интерфейса'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'При получении опций интерфейса произошла ошибка:
			   |%1'"),
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
		ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
	КонецПопытки;
	
	Возврат ОпцииИнтерфейса;
КонецФункции

// Доступность объектов метаданных по функциональным опциям.
Функция ДоступностьОбъектовПоОпциям() Экспорт
	Параметры = ОбщегоНазначенияПовтИсп.ОпцииИнтерфейса();
	Если ТипЗнч(Параметры) = Тип("ФиксированнаяСтруктура") Тогда
		Параметры = Новый Структура(Параметры);
	КонецЕсли;
	
	ДоступностьОбъектов = Новый Соответствие;
	Для Каждого ФункциональнаяОпция Из Метаданные.ФункциональныеОпции Цикл
		Значение = -1;
		Для Каждого Элемент Из ФункциональнаяОпция.Состав Цикл
			Если Значение = -1 Тогда
				Значение = ПолучитьФункциональнуюОпцию(ФункциональнаяОпция.Имя, Параметры);
			КонецЕсли;
			Если Значение = Истина Тогда
				ДоступностьОбъектов.Вставить(Элемент.Объект, Истина);
			Иначе
				Если ДоступностьОбъектов[Элемент.Объект] = Неопределено Тогда
					ДоступностьОбъектов.Вставить(Элемент.Объект, Ложь);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	Возврат ДоступностьОбъектов;
КонецФункции

//[РКХ->]
//Возвращает идентификатор рабочей конфигурации
//
Функция ИдентификаторРабочейКонфигурации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат СокрЛП(Строка(Константы.FiscalParentCompany.Получить()));
	               	
КонецФункции // [<-РКХ]

#КонецОбласти
