// Конвертация Logelco (documents) от 19.08.2016 14:23:54
#Область ПроцедурыКонвертации
Процедура ПередКонвертацией(КомпонентыОбмена) Экспорт
	
КонецПроцедуры

Процедура ПослеКонвертации(КомпонентыОбмена) Экспорт
	
КонецПроцедуры

Процедура ПередОтложеннымЗаполнением(КомпонентыОбмена) Экспорт
	
КонецПроцедуры

#КонецОбласти
#Область ПОД
// Заполняет таблицу правил обработки данных.
//
// Параметры:
//  НаправлениеОбмена - строка ("Отправка" либо "Получение").
//  ПравилаОбработкиДанных - таблица значений, в которую добавляются правила. 
Процедура ЗаполнитьПравилаОбработкиДанных(НаправлениеОбмена, ПравилаОбработкиДанных) Экспорт
	Если НаправлениеОбмена = "Отправка" Тогда
	Если ПравилаОбработкиДанных.Колонки.Найти("ОчисткаДанных") = Неопределено Тогда
	    ПравилаОбработкиДанных.Колонки.Добавить("ОчисткаДанных");
	КонецЕсли;
		ДобавитьПОД_Документ_РеализацияТоваровУслуг_Отправка(ПравилаОбработкиДанных);
		ДобавитьПОД_Документ_СчетФактураВыданный_Отправка(ПравилаОбработкиДанных);
		ДобавитьПОД_Справочник_TriggerTypes_Отправка(ПравилаОбработкиДанных);
		ДобавитьПОД_Справочник_ДоговорыКонтрагентов_Отправка(ПравилаОбработкиДанных);
	КонецЕсли;
КонецПроцедуры

#Область Отправка
#Область Документ_РеализацияТоваровУслуг_Отправка
Процедура ДобавитьПОД_Документ_РеализацияТоваровУслуг_Отправка(ПравилаОбработкиДанных)
	ПравилоОбработки = ПравилаОбработкиДанных.Добавить();
	ПравилоОбработки.Имя = "Документ_РеализацияТоваровУслуг_Отправка";
	ПравилоОбработки.ОбъектВыборкиМетаданные = Метаданные.Документы.РеализацияТоваровУслуг;
	ПравилоОбработки.ПриОбработке = "ПОД_Документ_РеализацияТоваровУслуг_Отправка_ПриОбработке";
	ПравилоОбработки.ОчисткаДанных = Ложь;
	ПравилоОбработки.ИспользуемыеПКО.Добавить("Документ_РеализацияТоваровУслуг_Отправка");
КонецПроцедуры

Процедура ПОД_Документ_РеализацияТоваровУслуг_Отправка_ПриОбработке(ДанныеИБ, ИспользованиеПКО, КомпонентыОбмена)
	ОбъектМетаданныхТекущий = ДанныеИБ.Метаданные();
	ПравилоОбработки = КомпонентыОбмена.ПравилаОбработкиДанных.Найти(ОбъектМетаданныхТекущий, "ОбъектВыборкиМетаданные");
	ОбработчикПриОбработке = ПравилоОбработки.ПриОбработке;
	ПравилоОбработки.ПриОбработке = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА НомераИнвойсовLawson.Тикет.Статус = ЗНАЧЕНИЕ(Перечисление.TicketsStatuses.Oracle)
	|			ТОГДА НомераИнвойсовLawson.Документ.Номер
	|		ИНАЧЕ НомераИнвойсовLawson.Номер
	|	КОНЕЦ КАК НомерИнвойса,
	|	ВЫБОР
	|		КОГДА НомераИнвойсовLawson.Тикет.Статус = ЗНАЧЕНИЕ(Перечисление.TicketsStatuses.Oracle)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ЭтоОракл
	|ИЗ
	|	РегистрСведений.НомераИнвойсовLawson КАК НомераИнвойсовLawson
	|ГДЕ
	|	НомераИнвойсовLawson.Документ = &Документ
	|	И ВЫБОР
	|			КОГДА НомераИнвойсовLawson.Тикет.Статус = ЗНАЧЕНИЕ(Перечисление.TicketsStatuses.Oracle)
	|				ТОГДА НомераИнвойсовLawson.Документ.Номер
	|			ИНАЧЕ НомераИнвойсовLawson.Номер
	|		КОНЕЦ <> """"";
	Запрос.УстановитьПараметр("Документ", ДанныеИБ.Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
	
		ДанныеИБ.ДополнительныеСвойства.Вставить("НомерИнвойса", Выборка.НомерИнвойса);
		ДанныеИБ.ДополнительныеСвойства.Вставить("ЭтоОракл", Выборка.ЭтоОракл);
		ОбменДаннымиXDTOСервер.ВыгрузкаОбъектаВыборки(КомпонентыОбмена, ДанныеИБ, ПравилоОбработки);
	
	КонецЦикла;
	
	ПравилоОбработки.ПриОбработке = ОбработчикПриОбработке;
	ИспользованиеПКО.Очистить();
КонецПроцедуры
#КонецОбласти
#Область Документ_СчетФактураВыданный_Отправка
Процедура ДобавитьПОД_Документ_СчетФактураВыданный_Отправка(ПравилаОбработкиДанных)
	ПравилоОбработки = ПравилаОбработкиДанных.Добавить();
	ПравилоОбработки.Имя = "Документ_СчетФактураВыданный_Отправка";
	ПравилоОбработки.ОбъектВыборкиМетаданные = Метаданные.Документы.СчетФактураВыданный;
	ПравилоОбработки.ПриОбработке = "ПОД_Документ_СчетФактураВыданный_Отправка_ПриОбработке";
	ПравилоОбработки.ОчисткаДанных = Ложь;
	ПравилоОбработки.ИспользуемыеПКО.Добавить("Документ_СчетФактураВыданный_Отправка");
КонецПроцедуры

Процедура ПОД_Документ_СчетФактураВыданный_Отправка_ПриОбработке(ДанныеИБ, ИспользованиеПКО, КомпонентыОбмена)
	ОбъектМетаданныхТекущий = ДанныеИБ.Метаданные();
	ПравилоОбработки = КомпонентыОбмена.ПравилаОбработкиДанных.Найти(ОбъектМетаданныхТекущий, "ОбъектВыборкиМетаданные");
	ОбработчикПриОбработке = ПравилоОбработки.ПриОбработке;
	ПравилоОбработки.ПриОбработке = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА НомераИнвойсовLawson.Тикет.Статус = ЗНАЧЕНИЕ(Перечисление.TicketsStatuses.Oracle)
	|			ТОГДА НомераИнвойсовLawson.Документ.Номер
	|		ИНАЧЕ НомераИнвойсовLawson.Номер
	|	КОНЕЦ КАК НомерИнвойса,
	|	ВЫБОР
	|		КОГДА НомераИнвойсовLawson.Тикет.Статус = ЗНАЧЕНИЕ(Перечисление.TicketsStatuses.Oracle)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ЭтоОракл
	|ИЗ
	|	РегистрСведений.НомераИнвойсовLawson КАК НомераИнвойсовLawson
	|ГДЕ
	|	НомераИнвойсовLawson.Документ = &Документ
	|	И ВЫБОР
	|			КОГДА НомераИнвойсовLawson.Тикет.Статус = ЗНАЧЕНИЕ(Перечисление.TicketsStatuses.Oracle)
	|				ТОГДА НомераИнвойсовLawson.Документ.Номер
	|			ИНАЧЕ НомераИнвойсовLawson.Номер
	|		КОНЕЦ <> """"";
	Запрос.УстановитьПараметр("Документ", ДанныеИБ.ДокументОснование);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
	
		ДанныеИБ.ДополнительныеСвойства.Вставить("НомерИнвойса", Выборка.НомерИнвойса);
		ДанныеИБ.ДополнительныеСвойства.Вставить("ЭтоОракл", Выборка.ЭтоОракл);
		ОбменДаннымиXDTOСервер.ВыгрузкаОбъектаВыборки(КомпонентыОбмена, ДанныеИБ, ПравилоОбработки);
	
	КонецЦикла;
	
	ПравилоОбработки.ПриОбработке = ОбработчикПриОбработке;
	ИспользованиеПКО.Очистить();
КонецПроцедуры
#КонецОбласти
#Область Справочник_TriggerTypes_Отправка
Процедура ДобавитьПОД_Справочник_TriggerTypes_Отправка(ПравилаОбработкиДанных)
	ПравилоОбработки = ПравилаОбработкиДанных.Добавить();
	ПравилоОбработки.Имя = "Справочник_TriggerTypes_Отправка";
	ПравилоОбработки.ОбъектВыборкиМетаданные = Метаданные.Справочники.ermTriggerTypes;
	ПравилоОбработки.ОчисткаДанных = Ложь;
	ПравилоОбработки.ИспользуемыеПКО.Добавить("Справочник_TriggerTypes_Отправка");
КонецПроцедуры
#КонецОбласти
#Область Справочник_ДоговорыКонтрагентов_Отправка
Процедура ДобавитьПОД_Справочник_ДоговорыКонтрагентов_Отправка(ПравилаОбработкиДанных)
	ПравилоОбработки = ПравилаОбработкиДанных.Добавить();
	ПравилоОбработки.Имя = "Справочник_ДоговорыКонтрагентов_Отправка";
	ПравилоОбработки.ОбъектВыборкиМетаданные = Метаданные.Справочники.ДоговорыКонтрагентов;
	ПравилоОбработки.ОчисткаДанных = Ложь;
	ПравилоОбработки.ИспользуемыеПКО.Добавить("Справочник_ДоговорыКонтрагентов_Отправка");
КонецПроцедуры
#КонецОбласти
#КонецОбласти

#КонецОбласти
#Область ПКО
// Заполняет таблицу правил конвертации объектов.
//
// Параметры:
//  НаправлениеОбмена - строка ("Отправка" либо "Получение").
//  ПравилаКонвертации - таблица значений, в которую добавляются правила. 
Процедура ЗаполнитьПравилаКонвертацииОбъектов(НаправлениеОбмена, ПравилаКонвертации) Экспорт
	Если НаправлениеОбмена = "Отправка" Тогда
		ДобавитьПКО_Документ_РеализацияТоваровУслуг_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Документ_СчетФактураВыданный_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Справочник_TriggerTypes_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Справочник_Валюты_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Справочник_ДоговорыКонтрагентов_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Справочник_Контрагенты_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Справочник_Организации_Отправка(ПравилаКонвертации);
		ДобавитьПКО_Справочник_Сегменты_Отправка(ПравилаКонвертации);
	КонецЕсли;
КонецПроцедуры

#Область Отправка
#Область Документ_РеализацияТоваровУслуг_Отправка
Процедура ДобавитьПКО_Документ_РеализацияТоваровУслуг_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Документ_РеализацияТоваровУслуг_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Документы.РеализацияТоваровУслуг;
	ПравилоКонвертации.ОбъектФормата = "Документ.Invoice";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ПриОтправкеДанных = "ПКО_Документ_РеализацияТоваровУслуг_Отправка_ПриОтправкеДанных";
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermDueDateFrom";
	НоваяСтрока.СвойствоФормата = "DueDateFrom";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermDueDateTo";
	НоваяСтрока.СвойствоФормата = "DueDateTo";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermTriggerDate";
	НоваяСтрока.СвойствоФормата = "TriggerDate";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ДоговорКонтрагента";
	НоваяСтрока.СвойствоФормата = "Contract";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Справочник_ДоговорыКонтрагентов_Отправка";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Номер";
	НоваяСтрока.СвойствоФормата = "Номер";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "СуммаДокумента";
	НоваяСтрока.СвойствоФормата = "FiscalAmount";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "FiscalInvoiceDate";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "FiscalInvoiceNumber";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "Source";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;

КонецПроцедуры

Процедура ПКО_Документ_РеализацияТоваровУслуг_Отправка_ПриОтправкеДанных(ДанныеИБ, ДанныеXDTO, КомпонентыОбмена, СтекВыгрузки)
	ТекНомерИнвойса = "#FailedToFind#";
	ДанныеИБ.ДополнительныеСвойства.Свойство("НомерИнвойса", ТекНомерИнвойса);
	ДанныеXDTO.КлючевыеСвойства.Номер = ТекНомерИнвойса;
	ДанныеXDTO.КлючевыеСвойства.Вставить("Source", ?(ДанныеИБ.ДополнительныеСвойства.ЭтоОракл, "OracleSmith", "Lawson"));
	
	СчетФактура = ОбщегоНазначения.НайтиПодчиненныйДокумент(ДанныеИБ.Ссылка, "СчетФактураВыданный");
	
	Если ЗначениеЗаполнено(СчетФактура) Тогда
		РеквизитыСчетФактуры = ОбщегоНазначения.ПолучитьЗначенияРеквизитов(СчетФактура, "Номер, Дата");
		ДанныеXDTO.Вставить("FiscalInvoiceNumber", РеквизитыСчетФактуры.Номер);
		ДанныеXDTO.Вставить("FiscalInvoiceDate", РеквизитыСчетФактуры.Дата);
	Иначе
		ДанныеXDTO.Вставить("FiscalInvoiceNumber", ДанныеИБ.Номер);
		ДанныеXDTO.Вставить("FiscalInvoiceDate", ДанныеИБ.Дата);
	КонецЕсли;
КонецПроцедуры
#КонецОбласти
#Область Документ_СчетФактураВыданный_Отправка
Процедура ДобавитьПКО_Документ_СчетФактураВыданный_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Документ_СчетФактураВыданный_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Документы.СчетФактураВыданный;
	ПравилоКонвертации.ОбъектФормата = "Документ.Invoice";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ПриОтправкеДанных = "ПКО_Документ_СчетФактураВыданный_Отправка_ПриОтправкеДанных";
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Дата";
	НоваяСтрока.СвойствоФормата = "FiscalInvoiceDate";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Номер";
	НоваяСтрока.СвойствоФормата = "FiscalInvoiceNumber";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Номер";
	НоваяСтрока.СвойствоФормата = "Номер";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "Contract";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "DueDateFrom";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "DueDateTo";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "FiscalAmount";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "Source";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "TriggerDate";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;

КонецПроцедуры

Процедура ПКО_Документ_СчетФактураВыданный_Отправка_ПриОтправкеДанных(ДанныеИБ, ДанныеXDTO, КомпонентыОбмена, СтекВыгрузки)
	ТекНомерИнвойса = "#FailedToFind#";
	ДанныеИБ.ДополнительныеСвойства.Свойство("НомерИнвойса", ТекНомерИнвойса);
	ДанныеXDTO.КлючевыеСвойства.Номер = ТекНомерИнвойса;
	ДанныеXDTO.КлючевыеСвойства.Вставить("Source", ?(ДанныеИБ.ДополнительныеСвойства.ЭтоОракл, "OracleSmith", "Lawson"));
	
	Если ЗначениеЗаполнено(ДанныеИБ.ДокументОснование) Тогда
		РеквизитыСчетФактуры = ОбщегоНазначения.ПолучитьЗначенияРеквизитов(ДанныеИБ.ДокументОснование, "ДоговорКонтрагента, ermDueDateFrom, ermDueDateTo, СуммаДокумента, ermTriggerDate");
		ДанныеXDTO.Вставить("Contract", РеквизитыСчетФактуры.ДоговорКонтрагента);
		ДанныеXDTO.Вставить("DueDateFrom", РеквизитыСчетФактуры.ermDueDateFrom);
		ДанныеXDTO.Вставить("DueDateTo", РеквизитыСчетФактуры.ermDueDateTo);
		ДанныеXDTO.Вставить("FiscalAmount", РеквизитыСчетФактуры.СуммаДокумента);
		ДанныеXDTO.Вставить("TriggerDate", РеквизитыСчетФактуры.ermTriggerDate);
	КонецЕсли;
КонецПроцедуры
#КонецОбласти
#Область Справочник_TriggerTypes_Отправка
Процедура ДобавитьПКО_Справочник_TriggerTypes_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Справочник_TriggerTypes_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Справочники.ermTriggerTypes;
	ПравилоКонвертации.ОбъектФормата = "Справочник.TriggerTypes";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Наименование";
	НоваяСтрока.СвойствоФормата = "Наименование";

КонецПроцедуры
#КонецОбласти
#Область Справочник_Валюты_Отправка
Процедура ДобавитьПКО_Справочник_Валюты_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Справочник_Валюты_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Справочники.Валюты;
	ПравилоКонвертации.ОбъектФормата = "Справочник.Валюты";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Код";
	НоваяСтрока.СвойствоФормата = "Код";

КонецПроцедуры
#КонецОбласти
#Область Справочник_ДоговорыКонтрагентов_Отправка
Процедура ДобавитьПКО_Справочник_ДоговорыКонтрагентов_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Справочник_ДоговорыКонтрагентов_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Справочники.ДоговорыКонтрагентов;
	ПравилоКонвертации.ОбъектФормата = "Справочник.Договоры";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ПриОтправкеДанных = "ПКО_Справочник_ДоговорыКонтрагентов_Отправка_ПриОтправкеДанных";
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmContractCurrency";
	НоваяСтрока.СвойствоФормата = "crmContractCurrency";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmContractID";
	НоваяСтрока.СвойствоФормата = "crmContractID";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmContractName";
	НоваяСтрока.СвойствоФормата = "crmContractName";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmContractValueUSD";
	НоваяСтрока.СвойствоФормата = "crmContractValueUSD";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmCreatedBy";
	НоваяСтрока.СвойствоФормата = "crmCreatedBy";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmCreatedDate";
	НоваяСтрока.СвойствоФормата = "crmCreatedDate";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmDFNName";
	НоваяСтрока.СвойствоФормата = "crmDFNName";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmEffectiveDate";
	НоваяСтрока.СвойствоФормата = "crmEffectiveDate";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmExpiryDate";
	НоваяСтрока.СвойствоФормата = "crmExpiryDate";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermAmendment";
	НоваяСтрока.СвойствоФормата = "Amendment";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermAmendmentName";
	НоваяСтрока.СвойствоФормата = "AmendmentName";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermContractID";
	НоваяСтрока.СвойствоФормата = "ContractID";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermDocumentFlowPeriodFrom";
	НоваяСтрока.СвойствоФормата = "DocumentFlowPeriodFrom";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermDocumentFlowPeriodTo";
	НоваяСтрока.СвойствоФормата = "DocumentFlowPeriodTo";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermPtDaysFrom";
	НоваяСтрока.СвойствоФормата = "PTDaysFrom";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermPtType";
	НоваяСтрока.СвойствоФормата = "PTType";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ermTrigger";
	НоваяСтрока.СвойствоФормата = "Trigger";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Справочник_TriggerTypes_Отправка";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "PIC_ID";
	НоваяСтрока.СвойствоФормата = "PIC_ID";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ВалютаВзаиморасчетов";
	НоваяСтрока.СвойствоФормата = "ВалютаВзаиморасчетов";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Справочник_Валюты_Отправка";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ВидДоговора";
	НоваяСтрока.СвойствоФормата = "ВидДоговора";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Перечисление_ВидыДоговоровКонтрагентов_Отправка";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Дата";
	НоваяСтрока.СвойствоФормата = "Дата";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Комментарий";
	НоваяСтрока.СвойствоФормата = "Комментарий";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Наименование";
	НоваяСтрока.СвойствоФормата = "Наименование";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Номер";
	НоваяСтрока.СвойствоФормата = "Номер";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Организация";
	НоваяСтрока.СвойствоФормата = "Организация";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Справочник_Организации_Отправка";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "РасчетыВУсловныхЕдиницах";
	НоваяСтрока.СвойствоФормата = "РасчетыВУсловныхЕдиницах";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "СрокДоговора";
	НоваяСтрока.СвойствоФормата = "СрокДействия";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "СрокОплаты";
	НоваяСтрока.СвойствоФормата = "PTDaysTo";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ТребуетсяChecklist";
	НоваяСтрока.СвойствоФормата = "ChecklistRequired";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "SourceID";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "УстановленСрокОплаты";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;
	ПравилоКонвертации.СвойстваТабличныхЧастей.Вставить("КодыCRMпоСегментам", ОбменДаннымиXDTOСервер.ИнициализироватьТаблицуСвойствДляПравилаКонвертации());
	СвойстваТЧ = ПравилоКонвертации.СвойстваТабличныхЧастей.КодыCRMпоСегментам;
	
	НоваяСтрока = СвойстваТЧ.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "crmContractID";
	НоваяСтрока.СвойствоФормата = "crmContractID";
	
	НоваяСтрока = СвойстваТЧ.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "PIC_ID";
	НоваяСтрока.СвойствоФормата = "PIC_ID";
	
	НоваяСтрока = СвойстваТЧ.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Segment";
	НоваяСтрока.СвойствоФормата = "Segment";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Справочник_Сегменты_Отправка";

КонецПроцедуры

Процедура ПКО_Справочник_ДоговорыКонтрагентов_Отправка_ПриОтправкеДанных(ДанныеИБ, ДанныеXDTO, КомпонентыОбмена, СтекВыгрузки)
	ДанныеXDTO.Вставить("УстановленСрокОплаты", Истина);
	ДанныеXDTO.Вставить("SourceID", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеИБ.ermSourceID, "Наименование"));
КонецПроцедуры
#КонецОбласти
#Область Справочник_Контрагенты_Отправка
Процедура ДобавитьПКО_Справочник_Контрагенты_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Справочник_Контрагенты_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Справочники.Контрагенты;
	ПравилоКонвертации.ОбъектФормата = "Справочник.Контрагенты";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	

КонецПроцедуры
#КонецОбласти
#Область Справочник_Организации_Отправка
Процедура ДобавитьПКО_Справочник_Организации_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Справочник_Организации_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Справочники.Организации;
	ПравилоКонвертации.ОбъектФормата = "Справочник.Организации";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ГоловнаяОрганизация";
	НоваяСтрока.СвойствоФормата = "ГоловнаяОрганизация";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Справочник_Организации_Отправка";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ИНН";
	НоваяСтрока.СвойствоФормата = "ИНН";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "КПП";
	НоваяСтрока.СвойствоФормата = "КПП";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "НаименованиеПолное";
	НоваяСтрока.СвойствоФормата = "НаименованиеПолное";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "НаименованиеСокращенное";
	НоваяСтрока.СвойствоФормата = "НаименованиеСокращенное";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "ЮридическоеФизическоеЛицо";
	НоваяСтрока.СвойствоФормата = "ЮридическоеФизическоеЛицо";
	НоваяСтрока.ПравилоКонвертацииСвойства = "Перечисление_ЮридическоеФизическоеЛицо_Отправка";

КонецПроцедуры
#КонецОбласти
#Область Справочник_Сегменты_Отправка
Процедура ДобавитьПКО_Справочник_Сегменты_Отправка(ПравилаКонвертации)

	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	ПравилоКонвертации.ИмяПКО = "Справочник_Сегменты_Отправка";
	ПравилоКонвертации.ОбъектДанных = Метаданные.Справочники.Сегменты;
	ПравилоКонвертации.ОбъектФормата = "Справочник.Сегменты";
	ПравилоКонвертации.ПравилоДляГруппыСправочника = Ложь;
	ПравилоКонвертации.ПриОтправкеДанных = "ПКО_Справочник_Сегменты_Отправка_ПриОтправкеДанных";
	ПравилоКонвертации.ВариантИдентификации = "ПоУникальномуИдентификатору";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоКонфигурации = "Код";
	НоваяСтрока.СвойствоФормата = "Код";
	
	НоваяСтрока = ПравилоКонвертации.Свойства.Добавить();
	НоваяСтрока.СвойствоФормата = "Source";
	НоваяСтрока.ИспользуетсяАлгоритмКонвертации = Истина;

КонецПроцедуры

Процедура ПКО_Справочник_Сегменты_Отправка_ПриОтправкеДанных(ДанныеИБ, ДанныеXDTO, КомпонентыОбмена, СтекВыгрузки)
	ДанныеXDTO.КлючевыеСвойства.Вставить("Source", "Lawson");
КонецПроцедуры
#КонецОбласти
#КонецОбласти

#КонецОбласти
#Область ПКПД
// Заполняет таблицу правил конвертации предопределенных данных.
//
// Параметры:
//  НаправлениеОбмена - строка ("Отправка" либо "Получение").
//  ПравилаКонвертации - таблица значений, в которую будут добавлены правила. 
Процедура ЗаполнитьПравилаКонвертацииПредопределенныхДанных(НаправлениеОбмена, ПравилаКонвертации) Экспорт
	Если НаправлениеОбмена = "Отправка" Тогда
		// Перечисление_ВидыДоговоровКонтрагентов_Отправка.
		ПравилоКонвертации = ПравилаКонвертации.Добавить();
		ПравилоКонвертации.ИмяПКПД = "Перечисление_ВидыДоговоровКонтрагентов_Отправка";
		ПравилоКонвертации.ТипДанных = Метаданные.Перечисления.ВидыДоговоровКонтрагентов;
		ПравилоКонвертации.ТипXDTO = "ВидыДоговоров";
	
		ЗначенияДляОтправки = Новый Соответствие;
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.Прочее, "Прочее");
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером, "СКомиссионером");
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку, "СКомиссионеромНаЗакупку");
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентом, "СКомитентом");
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентомНаЗакупку, "СКомитентомНаЗакупку");
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СПокупателем, "СПокупателем");
		ЗначенияДляОтправки.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком, "СПоставщиком");
		ПравилоКонвертации.КонвертацииЗначенийПриОтправке = ЗначенияДляОтправки;
	
		// Перечисление_ЮридическоеФизическоеЛицо_Отправка.
		ПравилоКонвертации = ПравилаКонвертации.Добавить();
		ПравилоКонвертации.ИмяПКПД = "Перечисление_ЮридическоеФизическоеЛицо_Отправка";
		ПравилоКонвертации.ТипДанных = Метаданные.Перечисления.ЮридическоеФизическоеЛицо;
		ПравилоКонвертации.ТипXDTO = "ЮридическоеФизическоеЛицо";
	
		ЗначенияДляОтправки = Новый Соответствие;
		ЗначенияДляОтправки.Вставить(Перечисления.ЮридическоеФизическоеЛицо.ИндивидуальныйПредприниматель, "ЮридическоеЛицо");
		ЗначенияДляОтправки.Вставить(Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо, "ФизическоеЛицо");
		ЗначенияДляОтправки.Вставить(Перечисления.ЮридическоеФизическоеЛицо.ЮридическоеЛицо, "ЮридическоеЛицо");
		ЗначенияДляОтправки.Вставить(Перечисления.ЮридическоеФизическоеЛицо.ЮрЛицоНеРезидент, "ЮридическоеЛицо");
		ПравилоКонвертации.КонвертацииЗначенийПриОтправке = ЗначенияДляОтправки;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти
#Область Алгоритмы



#КонецОбласти
#Область Параметры
// Заполняет параметры конвертации.
//
// Параметры:
//  ПараметрыКонвертации - структура, в которую добавляются параметры конвертации.
Процедура ЗаполнитьПараметрыКонвертации(ПараметрыКонвертации) Экспорт
КонецПроцедуры

#КонецОбласти
#Область ОбщегоНазначения
// Процедура-обертка, выполняет запуск указанной в параметрах процедуры модуля менеджера обмена через формат.
//
// Параметры:
//  ИмяПроцедуры - строка.
//  СтруктураПараметров - структура, содержащая передаваемые параметры.
Процедура ВыполнитьПроцедуруМодуляМенеджера(ИмяПроцедуры, Параметры) Экспорт
	Если ИмяПроцедуры = "ПОД_Документ_РеализацияТоваровУслуг_Отправка_ПриОбработке" Тогда 
		ПОД_Документ_РеализацияТоваровУслуг_Отправка_ПриОбработке(
			Параметры.ОбъектОбработки, Параметры.ИспользованиеПКО, Параметры.КомпонентыОбмена);
	ИначеЕсли ИмяПроцедуры = "ПОД_Документ_СчетФактураВыданный_Отправка_ПриОбработке" Тогда 
		ПОД_Документ_СчетФактураВыданный_Отправка_ПриОбработке(
			Параметры.ОбъектОбработки, Параметры.ИспользованиеПКО, Параметры.КомпонентыОбмена);
	ИначеЕсли ИмяПроцедуры = "ПКО_Документ_РеализацияТоваровУслуг_Отправка_ПриОтправкеДанных" Тогда 
		ПКО_Документ_РеализацияТоваровУслуг_Отправка_ПриОтправкеДанных(
			Параметры.ДанныеИБ, Параметры.ДанныеXDTO, Параметры.КомпонентыОбмена, Параметры.СтекВыгрузки);
	ИначеЕсли ИмяПроцедуры = "ПКО_Документ_СчетФактураВыданный_Отправка_ПриОтправкеДанных" Тогда 
		ПКО_Документ_СчетФактураВыданный_Отправка_ПриОтправкеДанных(
			Параметры.ДанныеИБ, Параметры.ДанныеXDTO, Параметры.КомпонентыОбмена, Параметры.СтекВыгрузки);
	ИначеЕсли ИмяПроцедуры = "ПКО_Справочник_ДоговорыКонтрагентов_Отправка_ПриОтправкеДанных" Тогда 
		ПКО_Справочник_ДоговорыКонтрагентов_Отправка_ПриОтправкеДанных(
			Параметры.ДанныеИБ, Параметры.ДанныеXDTO, Параметры.КомпонентыОбмена, Параметры.СтекВыгрузки);
	ИначеЕсли ИмяПроцедуры = "ПКО_Справочник_Сегменты_Отправка_ПриОтправкеДанных" Тогда 
		ПКО_Справочник_Сегменты_Отправка_ПриОтправкеДанных(
			Параметры.ДанныеИБ, Параметры.ДанныеXDTO, Параметры.КомпонентыОбмена, Параметры.СтекВыгрузки);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти
