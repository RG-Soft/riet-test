#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура СформироватьОтчет(Знач СтруктураПараметров, АдресХранилища) Экспорт

	Если ЗначениеЗаполнено(СтруктураПараметров.КонтрагентДляОтбора)
		ИЛИ СтруктураПараметров.ВыводитьПокупателейПоАвансам
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
			Результат = УчетНДС.ПолучитьЗаписиКнигиПокупок(СписокСчетовФактур, СтруктураПараметров);
		КонецЕсли;
		СформироватьОсновнойРаздел(СтруктураПараметров, Результат, СписокСчетовФактур);
		
	КонецЕсли;
		
	// Проверка наличия дополнительных листов за текущий период
	СтруктураПараметров = УчетНДС.ПроверитьНаличиеДопЛистовКнигиПокупок(СтруктураПараметров);
	
	Если СтруктураПараметров.ДополнительныеЛистыЗаТекущийПериод ИЛИ НЕ СтруктураПараметров.ФормироватьДополнительныеЛисты Тогда
		Если СтруктураПараметров.КорректируемыйПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета были внесены изменения в предшествующие налоговые периоды. 
				|Дополнительные листы по корректируемым налоговым периодам, в которые внесены изменения, можно построить в текущем отчете. 
				|Для этого необходимо взвести флажок ""Формировать дополнительные листы"" и выбрать значение ""за корректируемый период""'"));
		КонецЕсли;
		Если СтруктураПараметров.ФормироватьДополнительныеЛисты И НЕ СтруктураПараметров.ТекущийПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета не вносились изменения в последующих налоговых периодах. 
				|Построение дополнительных листов за текущий налоговый период не требуется'"));
		КонецЕсли;
	КонецЕсли;
	Если НЕ СтруктураПараметров.ДополнительныеЛистыЗаТекущийПериод ИЛИ НЕ СтруктураПараметров.ФормироватьДополнительныеЛисты Тогда
		Если СтруктураПараметров.ТекущийПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета есть изменения, внесенные в последующих налоговых периодах. 
				|Дополнительные листы по текущему налоговому периоду можно построить в текущем отчете.
				|Для этого необходимо взвести флажок ""Формировать дополнительные листы"" и выбрать значение ""за текущий период""!'"));
		КонецЕсли;
		Если СтруктураПараметров.ФормироватьДополнительныеЛисты И НЕ СтруктураПараметров.КорректируемыйПериод Тогда
			СписокСообщений.Добавить(НСтр("ru = 'В указанном периоде отчета не вносились изменения в предыдущие налоговые периоды. 
				|Построение дополнительных листов за корректируемый налоговый период не требуется'"));
		КонецЕсли;
	КонецЕсли;
	
	Если СтруктураПараметров.ФормироватьДополнительныеЛисты Тогда
		
		СписокСчетовФактур = Неопределено;
		СтруктураПараметров.ЗаписьДополнительногоЛиста = Истина;
		
		// Получение записей дополнительных листов
		Результат = УчетНДС.ПолучитьЗаписиДополнительныхЛистовКнигиПокупок(СписокСчетовФактур, СтруктураПараметров);
		СформироватьДополнительныеЛисты(СтруктураПараметров, Результат, СписокСчетовФактур);
		
	КонецЕсли;
	
	Если ДанныеДляПроверкиКонтрагентов.ИспользованиеПроверкиВозможно
		И НЕ ДанныеДляПроверкиКонтрагентов.ВыводитьТолькоНекорректныхКонтрагентов
		И СтруктураПараметров.Свойство("АдресДанныхКниги") Тогда
		ДанныеДляПроверкиКонтрагентов.Вставить("АдресДанныхКниги", СтруктураПараметров.АдресДанныхКниги);
	КонецЕсли;
	
	Результат = Новый Структура(
		"СписокСформированныхЛистов,СписокСообщений,ОткрыватьПомощникИзМакета,
		|ДанныеДляПроверкиКонтрагентов,ТаблицаРаздел8,ТаблицаРаздел81,ТабличныйДокументРаздел81,
		|ИтогиРаздел8,ИтогиРаздел81",
			СтруктураПараметров.СписокСформированныхЛистов,
			СписокСообщений,
			СтруктураПараметров.ОткрыватьПомощникИзМакета,
			ДанныеДляПроверкиКонтрагентов,
			СтруктураПараметров.ТаблицаРаздел8,
			СтруктураПараметров.ТаблицаРаздел81,
			СтруктураПараметров.ТабличныйДокументРаздел81,
			СтруктураПараметров.ИтогиРаздел8,
			СтруктураПараметров.ИтогиРаздел81);
	
	ПоместитьВоВременноеХранилище(Результат, АдресХранилища);
	
КонецПроцедуры
	
Процедура СформироватьОсновнойРаздел(СтруктураПараметров, Результат, СписокСчетовФактур);
	
	ДанныеДляПроверкиКонтрагентов = СтруктураПараметров.ДанныеДляПроверкиКонтрагентов;
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.Очистить();
	ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_КнигаПокупок";
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ЧерноБелаяПечать = Истина;
	
	Если СтруктураПараметров.ОткрыватьПомощникИзМакета Тогда
		ТабличныйДокумент.Вывести(УчетНДСПереопределяемый.ПолучитьМакетОткрытияПомощника(
			СтруктураПараметров.Организация, СтруктураПараметров.НачалоПериода));
	КонецЕсли;
	
	ВерсияПостановленияНДС1137 = УчетНДСПереопределяемый.ВерсияПостановленияНДС1137(СтруктураПараметров.КонецПериода);
	// { RGS LFedotova 20.01.2018 23:10:58 - вопрос SLI-0007468
	Если ВерсияПостановленияНДС1137 = 4 Тогда
		Макет = ПолучитьОбщийМакет("КнигаПокупок981");
	// } RGS LFedotova 20.01.2018 23:11:16 - вопрос SLI-0007468 
	ИначеЕсли ВерсияПостановленияНДС1137 = 3 Тогда
		Макет = ПолучитьОбщийМакет("КнигаПокупок735");
	Иначе
		Макет = ПолучитьОбщийМакет("КнигаПокупок1137");
	КонецЕсли;
	
	Если СтруктураПараметров.ЗаполнениеДекларации Тогда
		
		Секция = Макет.ПолучитьОбласть("ШапкаРаздел8");
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
		
		Если СтруктураПараметров.СформироватьОтчетПоСтандартнойФорме
			И НЕ СтруктураПараметров.ЗаполнениеДекларации Тогда
			ВывестиПодвал(СтруктураПараметров, ТабличныйДокумент, Макет);
		КонецЕсли;

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
	
	УчетНДС.ПреобразоватьЗаписиКнигиПокупок(
		СтруктураПараметров, Результат, ТабличныйДокумент,
		СписокСчетовФактур, ИтогПоОрганизации, ПараметрыСтроки,
		СтруктураПараметров.ТаблицаРаздел8, СтруктураСекций);
	
	// Вывод всего
	
	Секция = Макет.ПолучитьОбласть("Всего");
	Секция.Параметры.Заполнить(ИтогПоОрганизации);
	
	ТабличныйДокумент.Вывести(Секция);
	
	Если СтруктураПараметров.СформироватьОтчетПоСтандартнойФорме
		И НЕ СтруктураПараметров.ЗаполнениеДекларации Тогда
		ВывестиПодвал(СтруктураПараметров, ТабличныйДокумент, Макет);
	КонецЕсли;
	
	ИтогиРаздел8 = Новый Структура("СумНДСВсКПк");
	ИтогиРаздел8.СумНДСВсКПк = ИтогПоОрганизации.НДС;
	СтруктураПараметров.ИтогиРаздел8 = ИтогиРаздел8;
	
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
	
	ИтогиРаздел81 = Новый Структура("СумНДСИтКПк,СумНДСИтП1Р8");

	ПараметрыПолученияИтогов = Новый Структура;
	ПараметрыПолученияИтогов.Вставить("НалоговыйПериод", НачалоКвартала(СтруктураПараметров.НачалоПериода));
	ПараметрыПолученияИтогов.Вставить("КонецНалоговогоПериода", КонецКвартала(СтруктураПараметров.НачалоПериода));
	ПараметрыПолученияИтогов.Вставить("ДатаФормированияДопЛиста", КонецКвартала(СтруктураПараметров.НачалоПериода));
	ПараметрыПолученияИтогов.Вставить("СписокОрганизаций", СтруктураПараметров.СписокОрганизаций);
	
	ИтогПоКнигеПокупок = УчетНДС.ПолучитьИтогиЗаПериодКнигаПокупок(ПараметрыПолученияИтогов);
	ИтогиРаздел81.СумНДСИтКПк = ИтогПоКнигеПокупок.НДС;
	
	Для Каждого ИтогПоПериодам ИЗ ДеревоЗаписей.Строки Цикл;
		
		НомерЛиста = 0;
		
		// Добавление новой страницы панели разделов для вывода доп. листа
		НомерОтображаемогоПериода = НомерОтображаемогоПериода + 1;
		НалоговыйПериод = ПредставлениеПериода(
			ИтогПоПериодам.НалоговыйПериод, КонецДня(ИтогПоПериодам.КонецНалоговогоПериода), "ФП = Истина");
		
		ТабличныйДокумент = Новый ТабличныйДокумент;
		ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
		ТабличныйДокумент.АвтоМасштаб = Истина;
		ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_КнигаПокупокДопЛист";
		
		Если СтруктураПараметров.ОткрыватьПомощникИзМакета Тогда
			ТабличныйДокумент.Вывести(УчетНДСПереопределяемый.ПолучитьМакетОткрытияПомощника(
				СтруктураПараметров.Организация, СтруктураПараметров.НачалоПериода));
		КонецЕсли;
		
		Для Каждого ИтогПоПериодамКорректировки ИЗ ИтогПоПериодам.Строки Цикл
			
			ВерсияПостановленияНДС1137 = УчетНДСПереопределяемый.ВерсияПостановленияНДС1137(
				ИтогПоПериодамКорректировки.КонецНалоговогоПериода);
			// { RGS LFedotova 20.01.2018 23:25:52 - вопрос SLI-0007468
			//Если ВерсияПостановленияНДС1137 = 1 Тогда
			//	Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок1137");
			//ИначеЕсли ВерсияПостановленияНДС1137 = 2 Тогда 	
			//	Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок952");
			//Иначе
			//	Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок735");
			//КонецЕсли; 
			Если ВерсияПостановленияНДС1137 = 4 Тогда
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок981");
			ИначеЕсли ВерсияПостановленияНДС1137 = 3 Тогда
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок735");
			ИначеЕсли ВерсияПостановленияНДС1137 = 2 Тогда 	
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок952");
			Иначе
				Макет = ПолучитьОбщийМакет("ДополнительныйЛистКнигиПокупок1137");
			КонецЕсли; 
			// } RGS LFedotova 20.01.2018 23:26:07 - вопрос SLI-0007468
			
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
				ВывестиШапкуРаздела81Декларации(ТабличныйДокумент, Макет, СтруктураПараметров, НомерЛиста);
			Иначе
				УчетНДС.ВывестиШапкуДопЛиста(ТабличныйДокумент, Макет, СтруктураПараметров, НомерЛиста);
			КонецЕсли;
			
			СтруктураПараметров.ДатаФормированияДопЛиста = ИтогПоПериодамКорректировки.ДатаОформления;
			
			ИтогЗаПериод = УчетНДС.ПолучитьИтогиЗаПериодКнигаПокупок(СтруктураПараметров);
			
			СтрокаИтого.Параметры.Заполнить(ИтогЗаПериод);
			
			ТабличныйДокумент.Вывести(СтрокаИтого);
			
			СтруктураСекций = Новый Структура("СекцияСтрока", Макет.ПолучитьОбласть("Строка"));
			ПараметрыСтроки = СтруктураСекций.СекцияСтрока.Параметры;
			
			Если СтруктураПараметров.ГруппироватьПоКонтрагентам Тогда
				СтруктураСекций.Вставить("СекцияКонтрагент", Макет.ПолучитьОбласть("Контрагент"));
				СтруктураСекций.Вставить("СекцияВсегоКонтрагент", Макет.ПолучитьОбласть("ВсегоКонтрагент"));
			КонецЕсли;
			
			УчетНДС.ПреобразоватьЗаписиДополнительногоЛистаКнигиПокупок(
				СтруктураПараметров, ИтогПоПериодамКорректировки, ИтогЗаПериод, 
				ТабличныйДокумент, СписокСчетовФактур, ПараметрыСтроки, 
				СтруктураПараметров.ТаблицаРаздел81, СтруктураСекций);
			
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
	
	ИтогиРаздел81.СумНДСИтП1Р8 = ИтогЗаПериод.НДС; // Итог с учетом всех дополнительных листов за налоговый период
	
	СтруктураПараметров.ИтогиРаздел81 = ИтогиРаздел81;
	СтруктураПараметров.ТабличныйДокументРаздел81 = ТабличныйДокумент;
	
КонецПроцедуры

Процедура ВывестиШапкуРаздела81Декларации(ТабличныйДокумент, Макет, СтруктураПараметров, НомерДополнительногоЛиста)
	
	ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
	
	Если НомерДополнительногоЛиста = 1 Тогда
		Секция = Макет.ПолучитьОбласть("ШапкаРаздел81");
		ТабличныйДокумент.Вывести(Секция);
	КонецЕсли;
	
	Секция = Макет.ПолучитьОбласть("ШапкаРаздел81НомерЛиста");
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

	Раздел8 = Новый ТаблицаЗначений;
	
	Раздел8.Колонки.Добавить("НомерПор", ОбщегоНазначения.ОписаниеТипаЧисло(12, 0));
	
	Раздел8.Колонки.Добавить("НомСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(0));
	Раздел8.Колонки.Добавить("ДатаСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(10));
		
	Раздел8.Колонки.Добавить("НомИспрСчФ", ОбщегоНазначения.ОписаниеТипаЧисло(3, 0));
	Раздел8.Колонки.Добавить("ДатаИспрСчФ", ОбщегоНазначения.ОписаниеТипаСтрока(10));
	
	Раздел8.Колонки.Добавить("НомКСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(0));
	Раздел8.Колонки.Добавить("ДатаКСчФПрод", ОбщегоНазначения.ОписаниеТипаСтрока(10));
	
	Раздел8.Колонки.Добавить("НомИспрКСчФ", ОбщегоНазначения.ОписаниеТипаЧисло(3, 0));
	Раздел8.Колонки.Добавить("ДатаИспрКСчФ", ОбщегоНазначения.ОписаниеТипаСтрока(10));
	
	Раздел8.Колонки.Добавить("НомТД", ОбщегоНазначения.ОписаниеТипаСтрока(0));
	Раздел8.Колонки.Добавить("ОКВ", ОбщегоНазначения.ОписаниеТипаСтрока(3));
	
	Раздел8.Колонки.Добавить("СтоимПокупВ", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	Раздел8.Колонки.Добавить("СумНДСВыч", ОбщегоНазначения.ОписаниеТипаЧисло(19, 2));
	
	Раздел8.Колонки.Добавить("КодВидОпер", Новый ОписаниеТипов("Массив"));
	
	Раздел8.Колонки.Добавить("ДокПдтвУпл", Новый ОписаниеТипов("Массив"));
	Раздел8.Колонки.Добавить("ДатаУчТов", Новый ОписаниеТипов("Массив"));
	
	Раздел8.Колонки.Добавить("СвПрод", Новый ОписаниеТипов("Массив"));
	Раздел8.Колонки.Добавить("СвПос"); // Тип не задается
	
	Раздел81 = Раздел8.СкопироватьКолонки();
	Раздел81.Колонки.СумНДСВыч.Имя = "СумНДС";
	
	СтруктураПараметров.Вставить("ТаблицаРаздел8", Раздел8);
	СтруктураПараметров.Вставить("ТаблицаРаздел81", Раздел81);
	СтруктураПараметров.Вставить("ТабличныйДокументРаздел81");
	
	ИтогиРаздел8 = Новый Структура("СумНДСВсКПк");
	ИтогиРаздел81 = Новый Структура("СумНДСИтКПк,СумНДСИтП1Р8");
	
	СтруктураПараметров.Вставить("ИтогиРаздел8", ИтогиРаздел8);
	СтруктураПараметров.Вставить("ИтогиРаздел81", ИтогиРаздел81);
	
КонецПроцедуры

#КонецЕсли