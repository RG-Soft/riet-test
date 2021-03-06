#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура СформироватьОтчет(Знач СтруктураПараметров, АдресХранилища) Экспорт
	
	Если ЗначениеЗаполнено(СтруктураПараметров.КонтрагентДляОтбора)
		ИЛИ СтруктураПараметров.ВыводитьПродавцовПоАвансам
		ИЛИ СтруктураПараметров.ГруппироватьПоКонтрагентам 
		ИЛИ УчетНДС.ЭтоОтчетПоНекорректнымКонтрагентам(СтруктураПараметров) Тогда
		СтандартнаяФорма = Ложь;
	Иначе
		СтандартнаяФорма = Истина;
	КонецЕсли;

	СтруктураПараметров.Вставить("СформироватьОтчетПоСтандартнойФорме", СтандартнаяФорма);
		
	//Обновление на бух. корп. 3.0.38.42
	//Если НЕ СтруктураПараметров.ВключатьОбособленныеПодразделения Тогда
	//	СписокОрганизацийОтбора = Новый СписокЗначений;
	//	СписокОрганизацийОтбора.Добавить(СтруктураПараметров.Организация);
	//Иначе
	//	СписокОрганизацийОтбора = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьСписокОбособленныхПодразделений(
	//		СтруктураПараметров.Организация);
	//КонецЕсли;
	//
	//СписокДоступныхОрганизаций = ОбщегоНазначенияБПВызовСервераПовтИсп.ВсеОрганизацииДанныеКоторыхДоступныПоRLS(ложь);
	СписокОрганизацийОтбора = Новый СписокЗначений;
	СписокОрганизацийОтбора.Добавить(СтруктураПараметров.Организация);
	СписокДоступныхОрганизаций = Новый Массив;
	СписокДоступныхОрганизаций.Добавить(СтруктураПараметров.Организация);
	//<=
		
	СписокОрганизаций = Новый СписокЗначений;
	
	Для Каждого ОрганизацияСписка Из СписокОрганизацийОтбора Цикл
		Если СписокДоступныхОрганизаций.Найти(ОрганизацияСписка.Значение) <> Неопределено Тогда 
			СписокОрганизаций.Добавить(ОрганизацияСписка.Значение);
		КонецЕсли;
	КонецЦикла;
	
	СтруктураПараметров.Вставить("СписокОрганизаций", СписокОрганизаций);
	СтруктураПараметров.Вставить("ЗаписьДополнительногоЛиста", Ложь);
	СтруктураПараметров.Вставить("СоответствиеСтрокиДопИнформацииПоСчетуФактуре");
	
	ИнициализироватьТаблицыДляДекларацииПоНДС(СтруктураПараметров);
	
	СтруктураПараметров.Вставить("ОткрыватьПомощникИзМакета");
	СтруктураПараметров.ОткрыватьПомощникИзМакета = 
		УчетНДСПереопределяемый.ОткрыватьПомощникИзМакета(СтруктураПараметров.Организация, СтруктураПараметров.НачалоПериода)
		И НЕ СтруктураПараметров.ЗаполнениеДекларации;
	
	СтруктураПараметров.СписокСформированныхЛистов.Очистить();
	СписокСообщений = Новый СписокЗначений();
	
	ДанныеДляПроверкиКонтрагентов = СтруктураПараметров.ДанныеДляПроверкиКонтрагентов;
	
	Если НЕ (СтруктураПараметров.ВыводитьТолькоДопЛисты И СтруктураПараметров.ФормироватьДополнительныеЛисты) Тогда
		
		СписокСчетовФактур = Неопределено;
		
		Если ДанныеДляПроверкиКонтрагентов.ИспользованиеПроверкиВозможно 
			И ДанныеДляПроверкиКонтрагентов.ВыводитьТолькоНекорректныхКонтрагентов Тогда
			Результат = ДанныеДляПроверкиКонтрагентов.ЗаписиКниги;
		Иначе
			Результат = УчетНДС.ПолучитьЗаписиКнигиПродаж(СписокСчетовФактур, СтруктураПараметров);
		КонецЕсли;
		
		СформироватьОсновнойРаздел(СтруктураПараметров, Результат, СписокСчетовФактур);
		
	КонецЕсли;
		
	// Проверка наличия дополнительных листов за текущий период
	СтруктураПараметров = УчетНДС.ПроверитьНаличиеДопЛистовКнигиПродаж(СтруктураПараметров);
	
	Если СтруктураПараметров.ДополнительныеЛистыЗаТекущийПериод Или Не СтруктураПараметров.ФормироватьДополнительныеЛисты Тогда
		Если СтруктураПараметров.КорректируемыйПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета были внесены изменения в предшествующие налоговые периоды. 
				|Дополнительные листы по корректируемым налоговым периодам, в которые внесены изменения, можно построить в текущем отчете. 
				|Для этого необходимо взвести флажок ""Формировать дополнительные листы"" и выбрать значение ""за корректируемый период""'"));
		КонецЕсли;
		Если СтруктураПараметров.ФормироватьДополнительныеЛисты И Не СтруктураПараметров.ТекущийПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета не вносились изменения в последующих налоговых периодах. 
				|Построение дополнительных листов за текущий налоговый период не требуется'"));
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ СтруктураПараметров.ДополнительныеЛистыЗаТекущийПериод Или Не СтруктураПараметров.ФормироватьДополнительныеЛисты Тогда
		Если СтруктураПараметров.ТекущийПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета есть изменения, внесенные в последующих налоговых периодах. 
				|Дополнительные листы по текущему налоговому периоду можно построить в текущем отчете.
				|Для этого необходимо взвести флажок ""Формировать дополнительные листы"" и выбрать значение ""за текущий период""!'"));
		КонецЕсли;
		Если СтруктураПараметров.ФормироватьДополнительныеЛисты И Не СтруктураПараметров.КорректируемыйПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета не вносились изменения в предыдущие налоговые периоды. 
				|Построение дополнительных листов за корректируемый налоговый период не требуется'"));
		КонецЕсли;
	КонецЕсли;
	
	Если СтруктураПараметров.ФормироватьДополнительныеЛисты Тогда
		
		СписокСчетовФактур = Неопределено;
		СтруктураПараметров.ЗаписьДополнительногоЛиста = Истина;
		
		// Получение записей дополнительных листов
		Результат = УчетНДС.ПолучитьЗаписиДополнительныхЛистовКнигиПродаж(СписокСчетовФактур, СтруктураПараметров);
		
		СформироватьДополнительныеЛисты(СтруктураПараметров, Результат, СписокСчетовФактур);
		
	КонецЕсли;
	
	Если ДанныеДляПроверкиКонтрагентов.ИспользованиеПроверкиВозможно 
		И НЕ ДанныеДляПроверкиКонтрагентов.ВыводитьТолькоНекорректныхКонтрагентов
		И СтруктураПараметров.Свойство("АдресДанныхКниги") Тогда
		ДанныеДляПроверкиКонтрагентов.Вставить("АдресДанныхКниги", СтруктураПараметров.АдресДанныхКниги);
	КонецЕсли;
	
	Результат = Новый Структура(
		"СписокСформированныхЛистов, СписокСообщений, ОткрыватьПомощникИзМакета,
		|ДанныеДляПроверкиКонтрагентов,ТаблицаРаздел9,ТаблицаРаздел91,ТабличныйДокументРаздел91,
		|ИтогиРаздел9,ИтогиРаздел91", 
			СтруктураПараметров.СписокСформированныхЛистов,
			СписокСообщений,
			СтруктураПараметров.ОткрыватьПомощникИзМакета,
			ДанныеДляПроверкиКонтрагентов,
			СтруктураПараметров.ТаблицаРаздел9,
			СтруктураПараметров.ТаблицаРаздел91,
			СтруктураПараметров.ТабличныйДокументРаздел91,
			СтруктураПараметров.ИтогиРаздел9,
			СтруктураПараметров.ИтогиРаздел91);
	
	ПоместитьВоВременноеХранилище(Результат, АдресХранилища);
	
КонецПроцедуры

Процедура СформироватьОсновнойРаздел(СтруктураПараметров, Результат, СписокСчетовФактур);
	
	ДанныеДляПроверкиКонтрагентов = СтруктураПараметров.ДанныеДляПроверкиКонтрагентов;
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.Очистить();
	ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_КнигаПродаж";
	ТабличныйДокумент.ЧерноБелаяПечать = Истина;
	
	Если СтруктураПараметров.ОткрыватьПомощникИзМакета Тогда
		ТабличныйДокумент.Вывести(УчетНДСПереопределяемый.ПолучитьМакетОткрытияПомощника(
			СтруктураПараметров.Организация, СтруктураПараметров.НачалоПериода));
	КонецЕсли;
	
	ВерсияПостановленияНДС1137 = УчетНДСПереопределяемый.ВерсияПостановленияНДС1137(СтруктураПараметров.КонецПериода);
	
	// { RGS LFedotova 20.01.2018 15:23:55 - вопрос SLI-0007469
	Если ВерсияПостановленияНДС1137 = 4 Тогда
		Макет = ПолучитьОбщийМакет("КнигаПродаж981");
	// } RGS LFedotova 20.01.2018 15:24:02 - вопрос SLI-0007469
	ИначеЕсли ВерсияПостановленияНДС1137 = 3 Тогда
		Макет = ПолучитьОбщийМакет("КнигаПродаж735");
	Иначе
		Макет = ПолучитьОбщийМакет("КнигаПродаж1137");
	КонецЕсли; 

	Если СтруктураПараметров.ЗаполнениеДекларации Тогда
		
		Секция = Макет.ПолучитьОбласть("ШапкаРаздел9");
		ТабличныйДокумент.Вывести(Секция);
		Секция = Макет.ПолучитьОбласть("СтрокиДляПовтора");
		ТабличныйДокумент.Вывести(Секция);
		
	Иначе
	
		Если СтруктураПараметров.СформироватьОтчетПоСтандартнойФорме Тогда
			Секция = Макет.ПолучитьОбласть("ШапкаИнформация");
			ТабличныйДокумент.Вывести(Секция);
		КонецЕсли;

		//Обновление на бух. корп. 3.0.38.42
		//СведенияОбОрганизации = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(СтруктураПараметров.Организация);
		СведенияОбОрганизации = КонтактнаяИнформация.СведенияОЮрФизЛице(СтруктураПараметров.Организация);
		//<=
		НазваниеОрганизации = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм");;
		
		Секция = Макет.ПолучитьОбласть("Шапка");
		Секция.Параметры.УстановленныйОтбор = "";
		Секция.Параметры.НачалоПериода = Формат(СтруктураПараметров.НачалоПериода, "ДФ=dd.MM.yyyy");
		Секция.Параметры.КонецПериода = Формат(СтруктураПараметров.КонецПериода, "ДФ=dd.MM.yyyy");
		Секция.Параметры.НазваниеОрганизации = НазваниеОрганизации;
		Секция.Параметры.ИННКППОрганизации = "" + СтруктураПараметров.Организация.ИНН 
			+ ?(НЕ ЗначениеЗаполнено(СтруктураПараметров.Организация.КПП), "", ("/" + СтруктураПараметров.Организация.КПП));
		
		Если НЕ СтруктураПараметров.СформироватьОтчетПоСтандартнойФорме И СтруктураПараметров.ОтбиратьПоКонтрагенту Тогда
			
			Если ОбщегоНазначения.ОбъектЯвляетсяГруппой(СтруктураПараметров.КонтрагентДляОтбора) Тогда
				НадписьОтбор = НСтр("ru='Отбор: Контрагент в группе %1'");
			Иначе
				НадписьОтбор = НСтр("ru='Отбор: Контрагент = %1'");
			КонецЕсли;
			Секция.Параметры.УстановленныйОтбор = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НадписьОтбор, СтруктураПараметров.КонтрагентДляОтбора);
			
		КонецЕсли;
		
		ТабличныйДокумент.Вывести(Секция);
		
	КонецЕсли;
	
	Если Результат.Пустой() Тогда
		
		Секция = Макет.ПолучитьОбласть("Всего");
		ТабличныйДокумент.Вывести(Секция);
		
		ВывестиПодвал(СтруктураПараметров, ТабличныйДокумент, Макет);
		
		УправлениеКолонтитулами.УстановитьКолонтитулы(ТабличныйДокумент);
		СтруктураПараметров.СписокСформированныхЛистов.Добавить(ТабличныйДокумент, Нстр("ru='Основной раздел'"));
		
		Возврат;
		
	КонецЕсли;
	
	СтруктураСекций = Новый Структура("СекцияСтрока", Макет.ПолучитьОбласть("Строка"));
	ПараметрыСтроки = СтруктураСекций.СекцияСтрока.Параметры;
	
	Если СтруктураПараметров.ГруппироватьПоКонтрагентам Тогда
		СтруктураСекций.Вставить("СекцияКонтрагент", Макет.ПолучитьОбласть("Контрагент"));
		СтруктураСекций.Вставить("СекцияВсегоКонтрагент", Макет.ПолучитьОбласть("ВсегоКонтрагент"));
	КонецЕсли;
	
	ИтогПоОрганизации = 0;
	
	УчетНДС.ПреобразоватьЗаписиКнигиПродаж(
		СтруктураПараметров, Результат, ТабличныйДокумент, 
		СписокСчетовФактур, ИтогПоОрганизации, ПараметрыСтроки,
		СтруктураПараметров.ТаблицаРаздел9, СтруктураСекций);
	
	// Вывод всего
	Секция = Макет.ПолучитьОбласть("Всего");
	Секция.Параметры.Заполнить(ИтогПоОрганизации);
	
	ТабличныйДокумент.Вывести(Секция);
	
	Если СтруктураПараметров.СформироватьОтчетПоСтандартнойФорме
		И НЕ СтруктураПараметров.ЗаполнениеДекларации Тогда
		ВывестиПодвал(СтруктураПараметров, ТабличныйДокумент, Макет);
	КонецЕсли;
	
	ИтогиРаздел9 = Новый Структура("СтПродБезНДС18,СтПродБезНДС10,СтПродБезНДС0,СумНДСВсКПр18,СумНДСВсКПр10,СтПродОсвВсКПр");
	ИтогиРаздел9.СтПродБезНДС18 = ИтогПоОрганизации.СуммаБезНДС18;
	ИтогиРаздел9.СтПродБезНДС10 = ИтогПоОрганизации.СуммаБезНДС10;
	ИтогиРаздел9.СтПродБезНДС0 = ИтогПоОрганизации.НДС0;
	ИтогиРаздел9.СумНДСВсКПр18 = ИтогПоОрганизации.НДС18;
	ИтогиРаздел9.СумНДСВсКПр10 = ИтогПоОрганизации.НДС10;
	ИтогиРаздел9.СтПродОсвВсКПр = ИтогПоОрганизации.СуммаСовсемБезНДС;
	
	СтруктураПараметров.ИтогиРаздел9 = ИтогиРаздел9;
	
	ТабличныйДокумент.ПовторятьПриПечатиСтроки = ТабличныйДокумент.Область("СтрокиДляПовтора");
	УправлениеКолонтитулами.УстановитьКолонтитулы(ТабличныйДокумент);
	
	СтруктураПараметров.СписокСформированныхЛистов.Добавить(ТабличныйДокумент, Нстр("ru='Основной раздел'"));
	
КонецПроцедуры

Процедура СформироватьДополнительныеЛисты(СтруктураПараметров, Результат, СписокСчетовФактур)
	
	Перем ТабличныйДокумент;
	
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	НомерОтображаемогоПериода = 0;
	
	ДеревоЗаписей = Результат.Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	ИтогиРаздел91 = Новый Структура(
		"ИтСтПродКПр18,ИтСтПродКПр10,ИтСтПродКПр0,СумНДСИтКПр18,СумНДСИтКПр10,ИтСтПродОсвКПр,
		|СтПродВсП1Р9_18,СтПродВсП1Р9_10,СтПродВсП1Р9_0,СумНДСВсП1Р9_18,СумНДСВсП1Р9_10,СтПродОсвП1Р9Вс");
		
	ПараметрыПолученияИтогов = Новый Структура;
	ПараметрыПолученияИтогов.Вставить("НалоговыйПериод", НачалоКвартала(СтруктураПараметров.НачалоПериода));
	ПараметрыПолученияИтогов.Вставить("КонецНалоговогоПериода", КонецКвартала(СтруктураПараметров.НачалоПериода));
	ПараметрыПолученияИтогов.Вставить("ДатаФормированияДопЛиста", КонецКвартала(СтруктураПараметров.НачалоПериода));
	ПараметрыПолученияИтогов.Вставить("СписокОрганизаций", СтруктураПараметров.СписокОрганизаций);
	
	ИтогПоКнигеПродаж = УчетНДС.ПолучитьИтогиЗаПериодКнигаПродаж(ПараметрыПолученияИтогов);
	
	ИтогиРаздел91.ИтСтПродКПр18  = ИтогПоКнигеПродаж.СуммаБезНДС18;
	ИтогиРаздел91.ИтСтПродКПр10  = ИтогПоКнигеПродаж.СуммаБезНДС10;
	ИтогиРаздел91.ИтСтПродКПр0   = ИтогПоКнигеПродаж.НДС0;
	ИтогиРаздел91.СумНДСИтКПр18  = ИтогПоКнигеПродаж.НДС18;
	ИтогиРаздел91.СумНДСИтКПр10  = ИтогПоКнигеПродаж.НДС10;
	ИтогиРаздел91.ИтСтПродОсвКПр = ИтогПоКнигеПродаж.СуммаСовсемБезНДС;
	
	Для Каждого ИтогПоПериодам ИЗ ДеревоЗаписей.Строки Цикл
		
		НомерЛиста = 0;
		
		НомерОтображаемогоПериода = НомерОтображаемогоПериода + 1;
		НалоговыйПериод = ПредставлениеПериода(
			ИтогПоПериодам.НалоговыйПериод, КонецДня(ИтогПоПериодам.КонецНалоговогоПериода), "ФП = Истина");
		
		ТабличныйДокумент = Новый ТабличныйДокумент;
		ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
		ТабличныйДокумент.АвтоМасштаб = Истина;
		
		Если СтруктураПараметров.ОткрыватьПомощникИзМакета Тогда
			ТабличныйДокумент.Вывести(УчетНДСПереопределяемый.ПолучитьМакетОткрытияПомощника(
				СтруктураПараметров.Организация, СтруктураПараметров.НачалоПериода));
		КонецЕсли;
		
		Для Каждого ИтогПоПериодамКорректировки ИЗ ИтогПоПериодам.Строки Цикл;
			
			ВерсияПостановленияНДС1137 = УчетНДСПереопределяемый.ВерсияПостановленияНДС1137(
				ИтогПоПериодамКорректировки.КонецНалоговогоПериода);
			// { RGS LFedotova 20.01.2018 17:38:41 - вопрос SLI-0007469
			//Если ВерсияПостановленияНДС1137 = 1 Тогда
			//	Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж1137");
			//ИначеЕсли ВерсияПостановленияНДС1137 = 2 Тогда
			//	Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж952");
			//Иначе
			//	Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж735");
			//КонецЕсли; 			
			
			Если ВерсияПостановленияНДС1137 = 4 Тогда
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж981");
			ИначеЕсли ВерсияПостановленияНДС1137 = 3 Тогда
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж735");
			ИначеЕсли ВерсияПостановленияНДС1137 = 2 Тогда
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж952");
			Иначе
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПродаж1137");
			КонецЕсли; 			
			// } RGS LFedotova 20.01.2018 17:38:59 - вопрос SLI-0007469

			Секция = Макет.ПолучитьОбласть("Строка");
			СтрокаИтого = Макет.ПолучитьОбласть("Итого");
			СтрокаВсего = Макет.ПолучитьОбласть("Всего");
			
			Если СтруктураПараметров.ГруппироватьПоКонтрагентам Тогда
				СекцияКонтрагент = Макет.ПолучитьОбласть("Контрагент");
				СекцияВсегоКонтрагент = Макет.ПолучитьОбласть("ВсегоКонтрагент");
			КонецЕсли;
			
			// Формирование шапки доп. листа
			ОкончаниеПредыдущегоРаздела = ТабличныйДокумент.ВысотаТаблицы;
			НомерЛиста = НомерЛиста + 1;
			
			СтруктураПараметров.Вставить("НалоговыйПериод", ИтогПоПериодамКорректировки.НалоговыйПериод);
			СтруктураПараметров.Вставить("КонецНалоговогоПериода", КонецКвартала(ИтогПоПериодамКорректировки.КонецНалоговогоПериода));
			СтруктураПараметров.Вставить("ДатаОформления", ИтогПоПериодамКорректировки.ДатаОформления);
			
			Если СтруктураПараметров.ЗаполнениеДекларации Тогда
				ВывестиШапкуРаздела91Декларации(ТабличныйДокумент, Макет, СтруктураПараметров, НомерЛиста);
			Иначе
				УчетНДС.ВывестиШапкуДопЛиста(ТабличныйДокумент, Макет, СтруктураПараметров, НомерЛиста);
			КонецЕсли;

			СтруктураПараметров.ДатаФормированияДопЛиста = ИтогПоПериодамКорректировки.ДатаОформления;
			
			ИтогЗаПериод = УчетНДС.ПолучитьИтогиЗаПериодКнигаПродаж(СтруктураПараметров);
			СтрокаИтого.Параметры.Заполнить(ИтогЗаПериод);
		
			ТабличныйДокумент.Вывести(СтрокаИтого);
			
			СтруктураСекций = Новый Структура("СекцияСтрока", Макет.ПолучитьОбласть("Строка"));
			ПараметрыСтроки = СтруктураСекций.СекцияСтрока.Параметры;
			
			Если СтруктураПараметров.ГруппироватьПоКонтрагентам Тогда
				СтруктураСекций.Вставить("СекцияКонтрагент", Макет.ПолучитьОбласть("Контрагент"));
				СтруктураСекций.Вставить("СекцияВсегоКонтрагент", Макет.ПолучитьОбласть("ВсегоКонтрагент"));
			КонецЕсли;
			
			УчетНДС.ПреобразоватьЗаписиДополнительногоЛистаКнигиПродаж(
				СтруктураПараметров, ИтогПоПериодамКорректировки, ИтогЗаПериод, 
				ТабличныйДокумент, СписокСчетовФактур, ПараметрыСтроки,
				СтруктураПараметров.ТаблицаРаздел91, СтруктураСекций);
			
			СтрокаВсего.Параметры.Заполнить(ИтогЗаПериод);
			ТабличныйДокумент.Вывести(СтрокаВсего);
			
			Если СтруктураПараметров.СформироватьОтчетПоСтандартнойФорме
				И НЕ СтруктураПараметров.ЗаполнениеДекларации Тогда
				ВывестиПодвал(СтруктураПараметров, ТабличныйДокумент, Макет);
			КонецЕсли;
			
		КонецЦикла;
		
		ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		СтруктураПараметров.СписокСформированныхЛистов.Добавить(ТабличныйДокумент, Нстр("ru='Доп.листы за'") + " " + НалоговыйПериод);
		
	КонецЦикла;
	
	СтруктураПараметров.ТабличныйДокументРаздел91 = ТабличныйДокумент;
	
	ИтогиРаздел91.СтПродВсП1Р9_18 = ИтогЗаПериод.СуммаБезНДС18;
	ИтогиРаздел91.СтПродВсП1Р9_10 = ИтогЗаПериод.СуммаБезНДС10;
	ИтогиРаздел91.СтПродВсП1Р9_0  = ИтогЗаПериод.НДС0;
	ИтогиРаздел91.СумНДСВсП1Р9_18 = ИтогЗаПериод.НДС18;
	ИтогиРаздел91.СумНДСВсП1Р9_10 = ИтогЗаПериод.НДС10;
	ИтогиРаздел91.СтПродОсвП1Р9Вс = ИтогЗаПериод.СуммаСовсемБезНДС;

	СтруктураПараметров.ИтогиРаздел91 = ИтогиРаздел91;
	
КонецПроцедуры

Процедура ВывестиШапкуРаздела91Декларации(ТабличныйДокумент, Макет, СтруктураПараметров, НомерДополнительногоЛиста)
	
	ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
	
	Если НомерДополнительногоЛиста = 1 Тогда
		Секция = Макет.ПолучитьОбласть("ШапкаРаздел91");
		ТабличныйДокумент.Вывести(Секция);
	КонецЕсли;
	
	Секция = Макет.ПолучитьОбласть("ШапкаРаздел91НомерЛиста");
	Секция.Параметры.НомерЛиста = НомерДополнительногоЛиста;
	Секция.Параметры.ДатаСоставления = Формат(СтруктураПараметров.ДатаОформления, "ДФ=dd.MM.yyyy");
	ТабличныйДокумент.Вывести(Секция);
	
	Секция = Макет.ПолучитьОбласть("СтрокиДляПовтора");
	ТабличныйДокумент.Вывести(Секция);
	
КонецПроцедуры

Процедура ВывестиПодвал(СтруктураПараметров, ТабличныйДокумент, Макет)
	
	//Обновление на бух. корп. 3.0.38.42
	//ОтветственныеЛица = ОтветственныеЛицаБП.ОтветственныеЛица(СтруктураПараметров.Организация, СтруктураПараметров.КонецПериода);
	ОтветственныеЛица = ОбщегоНазначения.ОтветственныеЛица(СтруктураПараметров.Организация, СтруктураПараметров.КонецПериода);
	//<=
	Если ОбщегоНазначенияБПВызовСервераПовтИсп.ЭтоЮрЛицо(СтруктураПараметров.Организация) Тогда
		ИмяРук = ОтветственныеЛица.РуководительПредставление;
		ИмяОрг = "";
		Свидетельство = "";
	Иначе
		ИмяРук = "";
		ИмяОрг = ОтветственныеЛица.РуководительПредставление;
		//Обновление на бух. корп. 3.0.38.42
		//СведенияОЮрФизЛице = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(СтруктураПараметров.Организация);
		СведенияОЮрФизЛице = КонтактнаяИнформация.СведенияОЮрФизЛице(СтруктураПараметров.Организация);
		//<=		
		Свидетельство = СведенияОЮрФизЛице.Свидетельство;
	КонецЕсли;

	Секция = Макет.ПолучитьОбласть("Подвал");
	Секция.Параметры.ИмяРук        = ИмяРук;
	Секция.Параметры.ИмяОрг        = ИмяОрг;
	Секция.Параметры.Свидетельство = Свидетельство;

	ТабличныйДокумент.Вывести(Секция);
	
КонецПроцедуры

Процедура ИнициализироватьТаблицыДляДекларацииПоНДС(СтруктураПараметров)

	Раздел9 = Новый ТаблицаЗначений;
	
	Раздел9.Колонки.Добавить("НомерПор", ОбщегоНазначения.ОписаниеТипаЧисло(12, 0));
	
	Раздел9.Колонки.Добавить("НомСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(0));
	Раздел9.Колонки.Добавить("ДатаСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(10));
		
	Раздел9.Колонки.Добавить("НомИспрСчФ", ОбщегоНазначения.ОписаниеТипаЧисло(3, 0));
	Раздел9.Колонки.Добавить("ДатаИспрСчФ", ОбщегоНазначения.ОписаниеТипаСтрока(10));
	
	Раздел9.Колонки.Добавить("НомКСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(0));
	Раздел9.Колонки.Добавить("ДатаКСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(10));
	
	Раздел9.Колонки.Добавить("НомИспрКСчФ", ОбщегоНазначения.ОписаниеТипаЧисло(3, 0));
	Раздел9.Колонки.Добавить("ДатаИспрКСчФ", ОбщегоНазначения.ОписаниеТипаСтрока(10));
	
	Раздел9.Колонки.Добавить("ОКВ", ОбщегоНазначения.ОписаниеТипаСтрока(3));
	
	Раздел9.Колонки.Добавить("СтоимПродСФВ", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел9.Колонки.Добавить("СтоимПродСФ", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	
	Раздел9.Колонки.Добавить("СтоимПродСФ18", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел9.Колонки.Добавить("СтоимПродСФ10", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел9.Колонки.Добавить("СтоимПродСФ0", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел9.Колонки.Добавить("СумНДССФ18", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел9.Колонки.Добавить("СумНДССФ10", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел9.Колонки.Добавить("СтоимПродОсв", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	
	Раздел9.Колонки.Добавить("КодВидОпер", Новый ОписаниеТипов("Массив"));
	Раздел9.Колонки.Добавить("ДокПдтвОпл", Новый ОписаниеТипов("Массив"));
	
	
	Раздел9.Колонки.Добавить("СвПокуп", Новый ОписаниеТипов("Массив"));
	Раздел9.Колонки.Добавить("СвПос"); // Тип не задается
	
	Раздел91 = Раздел9.СкопироватьКолонки();
	
	СтруктураПараметров.Вставить("ТаблицаРаздел9", Раздел9);
	СтруктураПараметров.Вставить("ТаблицаРаздел91", Раздел91);
	СтруктураПараметров.Вставить("ТабличныйДокументРаздел91");
	
	ИтогиРаздел9 = Новый Структура("СтПродБезНДС18,СтПродБезНДС10,СтПродБезНДС0,СумНДСВсКПр18,СумНДСВсКПр10,СтПродОсвВсКПр");
	ИтогиРаздел91 = Новый Структура(
		"ИтСтПродКПр18,ИтСтПродКПр10,ИтСтПродКПр0,СумНДСИтКПр18,СумНДСИтКПр10,ИтСтПродОсвКПр,
		|СтПродВсП1Р9_18,СтПродВсП1Р9_10,СтПродВсП1Р9_0,СумНДСВсП1Р9_18,СумНДСВсП1Р9_10,СтПродОсвП1Р9Вс");
	
	СтруктураПараметров.Вставить("ИтогиРаздел9", ИтогиРаздел9);
	СтруктураПараметров.Вставить("ИтогиРаздел91", ИтогиРаздел91);
	
КонецПроцедуры


#КонецЕсли