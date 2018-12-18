/////////////////////////////////////////////////////////////
//ВЕРСИЯ ПРОЦЕДУР И ФУНКЦИЙ ОБЛАСТИ "ТиповаяБухгалтерия": БУХ. КОРП. 3.0.38.43 бета

#Область ТиповаяБухгалтерия

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	ПЕЧАТЬ СЧЕТОВ-ФАКТУР

Функция ПечатьСчетовФактур(МассивОбъектов, ОбъектыПечати, ТекстЗапросаПоСчетамФактурам) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.АвтоМасштаб			= Истина;
	ТабДокумент.ПолеСверху			= 0;
	ТабДокумент.ПолеСнизу			= 0;
	ТабДокумент.ОриентацияСтраницы	= ОриентацияСтраницы.Ландшафт;
	
	СисИнфо = Новый СистемнаяИнформация;
	Если ПустаяСтрока(СисИнфо.ИнформацияПрограммыПросмотра) Тогда 
		ТабДокумент.ПолеСлева          = 0;
		ТабДокумент.ПолеСправа         = 0;
	Иначе
		ТабДокумент.ПолеСлева          = 10;
		ТабДокумент.ПолеСправа         = 10;
	КонецЕсли;
	
	ТабДокумент.ИмяПараметровПечати	= "ПАРАМЕТРЫ_ПЕЧАТИ_СчетФактураВыданный_СчетФактура451";

	Макет = УправлениеПечатью.МакетПечатнойФормы("ОбщийМакет.ПФ_MXL_СчетФактура451");

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	Запрос.УстановитьПараметр("НачалоПримененияПостановления1137", УчетНДСБП.ПолучитьДатуНачалаДействияПостановления1137());
	Запрос.Текст	= ТекстЗапросаПоСчетамФактурам;
	Результаты		= Запрос.ВыполнитьПакет();

	ПервыйДокумент = Истина;

	ВыборкаСФ	= Результаты[0].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "СчетФактура");
	
	ПлатежноРасчетныеДокументы	= Неопределено;
	Если Результаты.Количество() > 1 И НЕ Результаты[1].Пустой() Тогда
		ПлатежноРасчетныеДокументы	= Результаты[1].Выгрузить();
		ПлатежноРасчетныеДокументы.Индексы.Добавить("СчетФактура");
	КонецЕсли;
	
	ДанныеСчетаФактуры = Новый Структура(
		"СчетФактура,ВидСчетаФактуры,Контрагент,ДоговорКонтрагента,ИспользуетсяПостановлениеНДС1137,НеподтверждениеНулевойСтавки,СводныйКомиссионный");
	ДанныеСчетаФактуры.ИспользуетсяПостановлениеНДС1137 = Ложь;
	ДанныеСчетаФактуры.НеподтверждениеНулевойСтавки = Ложь;
	ДанныеСчетаФактуры.СводныйКомиссионный = Ложь;
	Пока ВыборкаСФ.Следующий() Цикл

		ТаблицаДокумента = Неопределено;
		ВыборкаПоОснованиям = ВыборкаСФ.Выбрать();
		Пока ВыборкаПоОснованиям.Следующий() Цикл
			Если НЕ ЗначениеЗаполнено(ВыборкаПоОснованиям.ДокументОснование) Тогда
				Продолжить;
			КонецЕсли;
			
			ЗаполнитьЗначенияСвойств(ДанныеСчетаФактуры, ВыборкаСФ);
			ПараметрыОснования = УчетНДС.ПодготовитьДанныеДляПечатиСчетовФактур(ВыборкаПоОснованиям.ДокументОснование, ДанныеСчетаФактуры);
			
			Если ПараметрыОснования.Реквизиты = Неопределено ИЛИ ПараметрыОснования.ТаблицаДокумента = Неопределено Тогда
				Продолжить;
			Иначе
				Реквизиты = ПараметрыОснования.Реквизиты[0];
			КонецЕсли; 
				
			Если ТаблицаДокумента = Неопределено Тогда
				ТаблицаДокумента = ПараметрыОснования.ТаблицаДокумента;
			Иначе
				ОбщегоНазначенияБПВызовСервера.ЗагрузитьВТаблицуЗначений(ПараметрыОснования.ТаблицаДокумента, ТаблицаДокумента);
			КонецЕсли;
		КонецЦикла;
		Если ТаблицаДокумента = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если НЕ ПервыйДокумент Тогда
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		ПервыйДокумент = Ложь;

		// Запомним номер строки, с которой начали выводить текущий документ.
		НомерСтрокиНачало = ТабДокумент.ВысотаТаблицы + 1;

		// Вывод шапки

		ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
		ДанныеШапки   = ПодготовитьДанныеШапкиСчетаФактуры(ВыборкаСФ, Реквизиты, ПлатежноРасчетныеДокументы);
		ОбластьМакета.Параметры.Заполнить(Реквизиты);
		ОбластьМакета.Параметры.Заполнить(ДанныеШапки);
		ПроставитьПрочеркиВПустыеПоляСчетаФактуры(ОбластьМакета);
		ТабДокумент.Вывести(ОбластьМакета);

		// Вывод заголовка таблицы

		ОбластьМакета = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
		ОбластьМакета.Параметры.Заполнить(Реквизиты);
		ТабДокумент.Вывести(ОбластьМакета);

		// Вывод табличной части

		ОбластьМакета = Макет.ПолучитьОбласть("Строка");

		Для каждого СтрокаДокумента Из ТаблицаДокумента Цикл

			ОбластьМакета.Параметры.Заполнить(СтрокаДокумента);
			Если ВыборкаСФ.ВидСчетаФактуры = Перечисления.ВидСчетаФактурыВыставленного.НаАванс Тогда
				ОбластьМакета.Параметры.СуммаБезНДС  = "--";
			КонецЕсли;	
			ПроставитьПрочеркиВПустыеПоляСчетаФактуры(ОбластьМакета);
			ТабДокумент.Вывести(ОбластьМакета);

		КонецЦикла;

		// Вывод итоговых сумм

		ОбластьМакета = Макет.ПолучитьОбласть("Итого");
		ОбластьМакета.Параметры.ИтогоСуммаНДС = ТаблицаДокумента.Итог("СуммаНДС");
		ОбластьМакета.Параметры.ИтогоВсего    = ТаблицаДокумента.Итог("Всего");
		ПроставитьПрочеркиВПустыеПоляСчетаФактуры(ОбластьМакета);
		ТабДокумент.Вывести(ОбластьМакета);

		// Вывод подвала

		ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
		ОбластьМакета.Параметры.Заполнить(ДанныеШапки);
		ТабДокумент.Вывести(ОбластьМакета);

		// В табличном документе зададим имя области, в которую был выведен объект.
		// Нужно для возможности печати покомплектно.
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДокумент,
			НомерСтрокиНачало, ОбъектыПечати, ВыборкаСФ.СчетФактура);

	КонецЦикла;

	Возврат ТабДокумент;

КонецФункции

Функция ПечатьКорректировочныхСчетовФактур(МассивОбъектов, ОбъектыПечати, ТекстЗапросаПоСчетамФактурам) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.АвтоМасштаб			= Истина;
	ТабДокумент.ПолеСверху			= 0;
	ТабДокумент.ПолеСнизу			= 0;
	ТабДокумент.ОриентацияСтраницы	= ОриентацияСтраницы.Ландшафт;
	
	СисИнфо = Новый СистемнаяИнформация;
	Если ПустаяСтрока(СисИнфо.ИнформацияПрограммыПросмотра) Тогда 
		ТабДокумент.ПолеСлева          = 0;
		ТабДокумент.ПолеСправа         = 0;
	Иначе
		ТабДокумент.ПолеСлева          = 10;
		ТабДокумент.ПолеСправа         = 10;
	КонецЕсли;
	
	ТабДокумент.ИмяПараметровПечати	= "ПАРАМЕТРЫ_ПЕЧАТИ_СчетФактураВыданный_КорректировочныйСчетФактура";

	Макет = УправлениеПечатью.МакетПечатнойФормы("ОбщийМакет.ПФ_MXL_КорректировочныйСчетФактура");

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	Запрос.УстановитьПараметр("НачалоПримененияПостановления1137", УчетНДСБП.ПолучитьДатуНачалаДействияПостановления1137());
	Запрос.Текст = ТекстЗапросаПоСчетамФактурам;
	Результаты    = Запрос.ВыполнитьПакет();

	ПервыйДокумент = Истина;

	ВыборкаСФ	= Результаты[0].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "СчетФактура");
	
	Пока ВыборкаСФ.Следующий() Цикл

		ТаблицаДокумента = Неопределено;
		ВыборкаПоОснованиям = ВыборкаСФ.Выбрать();
		Пока ВыборкаПоОснованиям.Следующий() Цикл
			Если НЕ ЗначениеЗаполнено(ВыборкаПоОснованиям.ДокументОснование) Тогда
				Продолжить;
			КонецЕсли;
			ПараметрыОснования = УчетНДС.ПодготовитьДанныеДляПечатиКорректировочныхСчетовФактур(
				ВыборкаПоОснованиям.ДокументОснование, ВыборкаСФ.СчетФактура, ВыборкаСФ.ВидСчетаФактуры, Истина);
				
			Если ПараметрыОснования.Реквизиты = Неопределено ИЛИ ПараметрыОснования.ТаблицаДокумента = Неопределено Тогда
				Продолжить;
			Иначе
				Реквизиты = ПараметрыОснования.Реквизиты[0];
			КонецЕсли; 
				
			Если ТаблицаДокумента = Неопределено Тогда
				ТаблицаДокумента = ПараметрыОснования.ТаблицаДокумента;
			Иначе
				ОбщегоНазначенияБПВызовСервера.ЗагрузитьВТаблицуЗначений(ПараметрыОснования.ТаблицаДокумента, ТаблицаДокумента);
			КонецЕсли;
		КонецЦикла;
		Если ТаблицаДокумента = Неопределено  Тогда
			Продолжить;
		КонецЕсли;
		
		Если НЕ ПервыйДокумент Тогда
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		ПервыйДокумент = Ложь;

		// Запомним номер строки, с которой начали выводить текущий документ.
		НомерСтрокиНачало = ТабДокумент.ВысотаТаблицы + 1;

		// Вывод шапки

		ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
		ДанныеШапки   = УчетНДС.ПодготовитьДанныеШапкиКорректировочногоСчетаФактуры1137(ВыборкаСФ, Реквизиты);
		
		ОбластьМакета.Параметры.Номер = ДанныеШапки.Номер;
		ОбластьМакета.Параметры.Дата  = Формат(ДанныеШапки.Дата, "ДЛФ=ДД; ДП=--");
		ОбластьМакета.Параметры.НаименованиеПродавца = ДанныеШапки.НаименованиеПродавца;
		ОбластьМакета.Параметры.АдресПродавца = ДанныеШапки.АдресПродавца;
		ОбластьМакета.Параметры.ИННКПППродавца = ДанныеШапки.ИННКПППродавца;
		ОбластьМакета.Параметры.НаименованиеПокупателя = ДанныеШапки.НаименованиеПокупателя;
		ОбластьМакета.Параметры.АдресПокупателя = ДанныеШапки.АдресПокупателя;
		ОбластьМакета.Параметры.ИННКПППокупателя = ДанныеШапки.ИННКПППокупателя;
		
		РеквизитыОснований = "";
		
		Для каждого Основание Из ДанныеШапки.ТаблицаРеквизитовОснований Цикл
			РеквизитыОснований = ?(РеквизитыОснований = "", РеквизитыОснований,РеквизитыОснований + ", ") + "№ " + Основание.НомерСчетаФактуры + " от " 
				+ Формат(Основание.ДатаСчетаФактуры, "ДЛФ=ДД; ДП=--");
		КонецЦикла;
	
		ОбластьМакета.Параметры.РеквизитыОснований = РеквизитыОснований;
	
		ТабДокумент.Вывести(ОбластьМакета);

		// Вывод заголовка таблицы

		ОбластьМакета = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
		ОбластьМакета.Параметры.Заполнить(Реквизиты);
		ТабДокумент.Вывести(ОбластьМакета);

		// Вывод табличной части

		ОбластьМакета = Макет.ПолучитьОбласть("Строка");

		Для каждого СтрокаДокумента Из ТаблицаДокумента Цикл

			ОбластьМакета.Параметры.Заполнить(СтрокаДокумента);
			ТабДокумент.Вывести(ОбластьМакета);

		КонецЦикла;

		// Вывод итоговых сумм

		ОбластьМакета = Макет.ПолучитьОбласть("Итого");
		ОбластьМакета.Параметры.РазницаБезНДСУменьшение	= ТаблицаДокумента.Итог("РазницаБезНДСУменьшение");
		ОбластьМакета.Параметры.РазницаБезНДСУвеличение	= ТаблицаДокумента.Итог("РазницаБезНДСУвеличение");
		ОбластьМакета.Параметры.РазницаСНДСУменьшение   = ТаблицаДокумента.Итог("РазницаСНДСУменьшение");
		ОбластьМакета.Параметры.РазницаСНДСУвеличение   = ТаблицаДокумента.Итог("РазницаСНДСУвеличение");
		ОбластьМакета.Параметры.РазницаНДСУменьшение    = ТаблицаДокумента.Итог("РазницаНДСУменьшение");
		ОбластьМакета.Параметры.РазницаНДСУвеличение    = ТаблицаДокумента.Итог("РазницаНДСУвеличение");
		ПроставитьПрочеркиВПустыеПоляСчетаФактуры(ОбластьМакета);
		ТабДокумент.Вывести(ОбластьМакета);

		// Вывод подвала

		ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
		ОбластьМакета.Параметры.Заполнить(ДанныеШапки);
		ТабДокумент.Вывести(ОбластьМакета);

		// В табличном документе зададим имя области, в которую был выведен объект.
		// Нужно для возможности печати покомплектно.
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДокумент,
			НомерСтрокиНачало, ОбъектыПечати, ВыборкаСФ.СчетФактура);

	КонецЦикла;

	Возврат ТабДокумент;

КонецФункции

Функция ПодготовитьДанныеШапкиСчетаФактуры(ВыборкаСФ, Реквизиты, ПлатежноРасчетныеДокументы)

	ДанныеШапки = Новый Структура;

	Если ВыборкаСФ.УдалитьПрефиксыИзНомера Тогда
		ДанныеШапки.Вставить("Номер", ПрефиксацияОбъектовКлиентСервер.ПолучитьНомерНаПечать(ВыборкаСФ.Номер, Истина, Ложь));
	Иначе
		ДанныеШапки.Вставить("Номер", ВыборкаСФ.Номер);
	КонецЕсли;
	ДанныеШапки.Вставить("Дата", Формат(ВыборкаСФ.Дата, "ДФ='дд ММММ гггг'") + " г.");

	СведенияОПоставщике = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(Реквизиты.Поставщик, ВыборкаСФ.Дата);
	ДанныеШапки.Вставить("ПредставлениеПоставщика",
		ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "НаименованиеДляПечатныхФорм,"));
	ДанныеШапки.Вставить("АдресПоставщика",
		ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "ЮридическийАдрес,"));
	ИНН = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "ИНН,", Ложь);
	ДанныеШапки.Вставить("ИННпоставщика",
		ИНН + ?(ЗначениеЗаполнено(Реквизиты.КППпоставщика), "/" + Реквизиты.КППпоставщика, ""));

	СведенияОПокупателе = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(Реквизиты.Покупатель, ВыборкаСФ.Дата);
	ДанныеШапки.Вставить("ПредставлениеПокупателя",
		ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПокупателе, "НаименованиеДляПечатныхФорм,"));
	ДанныеШапки.Вставить("АдресПокупателя",
		ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПокупателе, "ЮридическийАдрес,"));
	ИНН = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПокупателе, "ИНН,", Ложь);
	КПП = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПокупателе, "КПП,", Ложь);
	ДанныеШапки.Вставить("ИННпокупателя",
		ИНН + ?(ЗначениеЗаполнено(КПП), "/" + КПП, ""));

	Если НЕ Реквизиты.ЕстьТовары Тогда
		ДанныеШапки.Вставить("ПредставлениеГрузоотправителя", "");
	ИначеЕсли ЗначениеЗаполнено(Реквизиты.Грузоотправитель)
		И ТипЗнч(Реквизиты.Грузоотправитель) <> Тип("Строка") Тогда
		СведенияОГрузоотправителе = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(Реквизиты.Грузоотправитель, ВыборкаСФ.Дата);
		ДанныеШапки.Вставить("ПредставлениеГрузоотправителя",
			ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОГрузоотправителе, "НаименованиеДляПечатныхФорм,ФактическийАдрес,"));
	Иначе
		ДанныеШапки.Вставить("ПредставлениеГрузоотправителя", Реквизиты.Грузоотправитель);
	КонецЕсли;

	Если НЕ Реквизиты.ЕстьТовары Тогда
		ДанныеШапки.Вставить("ПредставлениеГрузополучателя", "");
	ИначеЕсли ЗначениеЗаполнено(Реквизиты.Грузополучатель) Тогда
		СведенияОГрузополучателе = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(Реквизиты.Грузополучатель, ВыборкаСФ.Дата);
		ДанныеШапки.Вставить("ПредставлениеГрузополучателя",
			ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОГрузополучателе, "НаименованиеДляПечатныхФорм,ФактическийАдрес,"));
	Иначе
		ДанныеШапки.Вставить("ПредставлениеГрузополучателя", Реквизиты.Грузополучатель);
	КонецЕсли;

	Если ВыборкаСФ.ЭтоСчетФактураВыданный Тогда
		Если ОбщегоНазначенияБПВызовСервераПовтИсп.ЭтоЮрЛицо(Реквизиты.Поставщик) Тогда
			//Обновление на бух. корп. 3.0.38.43
			Руководители = ОбщегоНазначения.ОтветственныеЛица(Реквизиты.Поставщик, ВыборкаСФ.Дата, Реквизиты.Подразделение);
			//<=			
			ДанныеШапки.Вставить("ФИОРуководителя", Руководители.РуководительПредставление);
			ДанныеШапки.Вставить("ФИОГлавногоБухгалтера", Руководители.ГлавныйБухгалтерПредставление);
		Иначе
			ДанныеШапки.Вставить("ФИОПБОЮЛ",		ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "ФамилияИнициалыФизлица,"));
			ДанныеШапки.Вставить("Свидетельство",	ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "Свидетельство,"));
		КонецЕсли;
	КонецЕсли;
	
	// Платежно-расчетный документ
	ПоДокументу = "";
	Если ТипЗнч(ПлатежноРасчетныеДокументы) = Тип("ТаблицаЗначений") Тогда
		Отбор = Новый Структура("СчетФактура", ВыборкаСФ.СчетФактура);
		НайденныеСтроки = ПлатежноРасчетныеДокументы.НайтиСтроки(Отбор);
		Для каждого ДокументОплаты Из НайденныеСтроки Цикл
			Если ЗначениеЗаполнено(ДокументОплаты.НомерДокумента)
				И ЗначениеЗаполнено(ДокументОплаты.ДатаДокумента) Тогда
				ПоДокументу = ПоДокументу + ?(ПустаяСтрока(ПоДокументу), "",", ")
					+ ДокументОплаты.НомерДокумента + " от " + Формат(ДокументОплаты.ДатаДокумента, "ДЛФ='Д'") + " г.";
			КонецЕсли;
		КонецЦикла; 
	КонецЕсли;
	Если ПустаяСтрока(ПоДокументу) Тогда
		ПоДокументу = "--";
	КонецЕсли;
	ДанныеШапки.Вставить("ПоДокументу", ПоДокументу);
	
	Если ВыборкаСФ.ЭтоСчетФактураВыданный
		И ТипЗнч(Реквизиты.Поставщик) = Тип("СправочникСсылка.Контрагенты") 
		И ТипЗнч(Реквизиты.Покупатель) = Тип("СправочникСсылка.Контрагенты") Тогда
		
		СведенияОКомиссионере = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(Реквизиты.Организация, ВыборкаСФ.Дата);
		
		НаименованиеКомиссионера = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОКомиссионере, "НаименованиеДляПечатныхФорм,");
		ЮридическийАдресКомиссионера = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОКомиссионере, "ЮридическийАдрес,");
		ИННКомиссионера = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОКомиссионере, "ИНН,", Ложь);
		КППКомиссионера = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОКомиссионере, "КПП,", Ложь);
		
		ДанныеШапки.Вставить("ПредставлениеКомиссионера", 
			"Составлен комиссионером (агентом): " + НаименованиеКомиссионера 
			+ ", " + ЮридическийАдресКомиссионера 
			+ ", ИНН/КПП: " + ИННКомиссионера 
			+ ?(ЗначениеЗаполнено(КППКомиссионера), "/" + КППКомиссионера, ""));
	Иначе
		ДанныеШапки.Вставить("ПредставлениеКомиссионера", "");
	КонецЕсли;		

    Возврат ДанныеШапки;

КонецФункции

// Проставляет прочерки в незаполненных полях печатной формы счета-фактуры
//
Процедура ПроставитьПрочеркиВПустыеПоляСчетаФактуры(ОбластьМакета)

	Для т = 0 По ОбластьМакета.Параметры.Количество() - 1 Цикл

		ТекПараметр = ОбластьМакета.Параметры.Получить(т);

		Если (Найти(ТекПараметр, "Продавец:") <> 0)
		   И (СокрЛП(ТекПараметр) = "Продавец:") Тогда
			ОбластьМакета.Параметры.Установить(т, "Продавец: ----");

		ИначеЕсли (Найти(ТекПараметр, "Адрес:") <> 0)
			И (СокрЛП(ТекПараметр) = "Адрес:") Тогда
			ОбластьМакета.Параметры.Установить(т, "Адрес: ----");

		ИначеЕсли (Найти(ТекПараметр, "Идентификационный номер продавца (ИНН):") <> 0)
			И (СокрЛП(ТекПараметр) = "Идентификационный номер продавца (ИНН):") Тогда
			ОбластьМакета.Параметры.Установить(т, "Идентификационный номер продавца (ИНН): ----");

		ИначеЕсли (Найти(ТекПараметр, "Грузоотправитель и его адрес:") <> 0)
			И (СокрЛП(ТекПараметр) = "Грузоотправитель и его адрес:") Тогда
			ОбластьМакета.Параметры.Установить(т, "Грузоотправитель и его адрес: ----");

		ИначеЕсли (Найти(ТекПараметр, "Грузополучатель и его адрес:") <> 0)
		   	И (СокрЛП(ТекПараметр) = "Грузополучатель и его адрес:") Тогда
			ОбластьМакета.Параметры.Установить(т, "Грузополучатель и его адрес: ----");

		ИначеЕсли (Найти(ТекПараметр, "К платежно-расчетному документу №") <> 0)
		   	И (СокрЛП(ТекПараметр) = "К платежно-расчетному документу №  от") Тогда
			ОбластьМакета.Параметры.Установить(т, "К платежно-расчетному документу № -- от --");

		ИначеЕсли (Найти(ТекПараметр, "Покупатель:") <> 0)
		   	И (СокрЛП(ТекПараметр) = "Покупатель:") Тогда
			ОбластьМакета.Параметры.Установить(т, "Покупатель: ----");

		ИначеЕсли (Найти(ТекПараметр, "Идентификационный номер покупателя (ИНН):") <> 0)
			И (СокрЛП(ТекПараметр) = "Идентификационный номер покупателя (ИНН):") Тогда
			ОбластьМакета.Параметры.Установить(т, "Идентификационный номер покупателя (ИНН): ----");

		ИначеЕсли НЕ ЗначениеЗаполнено(ТекПараметр) Тогда
			ОбластьМакета.Параметры.Установить(т, "--");

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура СформироватьДвиженияРублевыеСуммыДокументовВВалюте(ТаблицаДокумента, ТаблицаРеквизиты, Движения, Отказ) Экспорт

	Параметры = ПодготовитьПараметрыРублевыеСуммыДокументовВВалюте(ТаблицаДокумента, ТаблицаРеквизиты);
	
	Если Параметры.Реквизиты.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;	
	
	Реквизиты = Параметры.Реквизиты[0];

	Если Реквизиты.ВалютаДокумента = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета() Тогда
		// Движения выполняются только для документов в иностранной валюте и у.е.
		Возврат;
	КонецЕсли;
	
	ВыполнитьДвиженияРублевыеСуммыДокументовВВалюте(Параметры.ТаблицаДокумента, Реквизиты, Истина, Ложь, Движения);
	
КонецПроцедуры

Функция ПодготовитьПараметрыРублевыеСуммыДокументовВВалюте(ТаблицаДокумента, ТаблицаРеквизиты)

	Параметры = Новый Структура;

	// Подготовка таблицы Реквизиты

	СписокОбязательныхКолонок = ""
	+ "Период,"                   // <Дата>
	+ "Регистратор,"              // <ДокументСсылка>
	+ "Организация,"              // <СправочникСсылка.Организации>
	+ "ВалютаДокумента"	  	  	  // <СправочникСсылка.Валюты>
	;
	Параметры.Вставить("Реквизиты", ОбщегоНазначенияБПВызовСервера.ПолучитьТаблицуПараметровПроведения(
		ТаблицаРеквизиты, СписокОбязательныхКолонок));

	// Подготовка таблицы по табличной части документа:
	СписокОбязательныхКолонок = ""
	+ "ИмяСписка,"  			  // <Строка>
	+ "НомерСтроки," 	  		  // <Число(5, 0)>
	+ "СуммаБезНДСРуб,"			  // <Число(15, 2)>
	+ "СуммаБУ,"				  // <Число(15, 2)>
	+ "СуммаНДСРуб"				  // <Число(15, 2)>
	;
	Параметры.Вставить("ТаблицаДокумента", ОбщегоНазначенияБПВызовСервера.ПолучитьТаблицуПараметровПроведения(
		ТаблицаДокумента, СписокОбязательныхКолонок));

	Возврат Параметры;

КонецФункции

Процедура ВыполнитьДвиженияРублевыеСуммыДокументовВВалюте(ТаблицаДокумента, Реквизиты, НДСВключенВСтоимость, БезНДС, Движения)
	
	// Свернем строки в таблице, чтобы не было дублей
	Если БезНДС Тогда
		ТаблицаДокумента.Свернуть("ИмяСписка, НомерСтроки", "СуммаРуб");
	Иначе
		ТаблицаДокумента.Свернуть("ИмяСписка, НомерСтроки", "СуммаБУ, СуммаНДСРуб, СуммаБезНДСРуб");
	КонецЕсли;

	Для Каждого СтрокаТаблицы Из ТаблицаДокумента Цикл
		// Определим табличную часть документа
		ТабличнаяЧастьДокумента = ПолучитьТабличнуюЧастьДокументаПоИмениСписка(СтрокаТаблицы.ИмяСписка, СтрокаТаблицы.НомерСтроки);
		
		Если ТабличнаяЧастьДокумента = Неопределено Тогда
			Продолжить;
		КонецЕсли;	
		
		Движение = Движения.РублевыеСуммыДокументовВВалюте.Добавить();
		// Свойства
		Движение.Период = Реквизиты.Период;
		
		// Измерения
		Движение.ТабличнаяЧастьДокумента 	= ТабличнаяЧастьДокумента;
		Движение.НомерСтрокиДокумента		= СтрокаТаблицы.НомерСтроки;
		Движение.Организация				= Реквизиты.Организация;
		
		// Ресурсы
		Если БезНДС Тогда
			
			Движение.Всего            = СтрокаТаблицы.СуммаРуб;
			Движение.НДС			  = 0;
			Движение.НалоговаяБазаНДС = 0;
			
		Иначе	
			
			Если НДСВключенВСтоимость Тогда
				Движение.Всего					= СтрокаТаблицы.СуммаБУ;
			Иначе
				Движение.Всего					= СтрокаТаблицы.СуммаБУ + СтрокаТаблицы.СуммаНДСРуб;
			КонецЕсли;
			
			Движение.НДС						= СтрокаТаблицы.СуммаНДСРуб;
			Движение.НалоговаяБазаНДС			= СтрокаТаблицы.СуммаБезНДСРуб;
			
		КонецЕсли;
		
	КонецЦикла;

	Движения.РублевыеСуммыДокументовВВалюте.Записывать = Истина;
	
КонецПроцедуры	

Функция ПолучитьТабличнуюЧастьДокументаПоИмениСписка(ИмяСписка, НомерСтрокиДокумента)

	// Определим табличную часть документа
	ИмяСпискаВРег = ВРег(ИмяСписка);
	ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ПустаяСсылка();
	Если НомерСтрокиДокумента = 0 Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ПустаяСсылка();
	ИначеЕсли НЕ ЗначениеЗаполнено(ИмяСписка) Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ПустаяСсылка();
	ИначеЕсли ИмяСпискаВРег = "ТОВАРЫ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.Товары;
	ИначеЕсли ИмяСпискаВРег = "УСЛУГИ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.Услуги;
	ИначеЕсли ИмяСпискаВРег = "АГЕНТСКИЕУСЛУГИ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.АгентскиеУслуги;
	ИначеЕсли ИмяСпискаВРег = "ВОЗВРАТНАЯТАРА" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ВозвратнаяТара;
	ИначеЕсли ИмяСпискаВРег = "ТАБЛИЦАНЕМАТЕРИАЛЬНЫЕАКТИВЫ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.НематериальныеАктивы;
	ИначеЕсли ИмяСпискаВРег = "НМА" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ПустаяСсылка();
	ИначеЕсли ИмяСпискаВРег = "ОБОРУДОВАНИЕ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.Оборудование;
	ИначеЕсли ИмяСпискаВРег = "ОБЪЕКТЫСТРОИТЕЛЬСТВА" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ОбъектыСтроительства;
	ИначеЕсли ИмяСпискаВРег = "ОПЛАТАПОСТАВЩИКАМ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ОплатаПоставщикам;
	ИначеЕсли ИмяСпискаВРег = "ОС" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ОС;
	ИначеЕсли ИмяСпискаВРег = "ТОВАРЫИУСЛУГИ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ТоварыИУслуги;
	ИначеЕсли ИмяСпискаВРег = "ПРОЧЕЕ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.Прочее;
	ИначеЕсли ИмяСпискаВРег = "ТОВАРЫДОИЗМЕНЕНИЯ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.ТоварыДоИзменения;
	ИначеЕсли ИмяСпискаВРег = "УСЛУГИДОИЗМЕНЕНИЯ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.УслугиДоИзменения;
	ИначеЕсли ИмяСпискаВРег = "АГЕНТСКИЕУСЛУГИДОИЗМЕНЕНИЯ" Тогда
		ТабличнаяЧастьДокумента = Перечисления.ТабличныеЧастиДокументов.АгентскиеУслугиДоИзменения;
	Иначе
		ТабличнаяЧастьДокумента = Неопределено;
	КонецЕсли;

	Возврат ТабличнаяЧастьДокумента;

КонецФункции

#КонецОбласти