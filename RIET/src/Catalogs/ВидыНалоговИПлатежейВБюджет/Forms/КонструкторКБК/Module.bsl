////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	РабочаяДата = ОбщегоНазначения.ТекущаяДатаПользователя();
	
	Если Параметры.Свойство("ВидПеречисления") Тогда
		ВидПеречисления = Параметры.ВидПеречисления;
	Иначе
		ВидПеречисления = Перечисления.ВидыПеречисленийВБюджет.НалоговыйПлатеж;
	КонецЕсли;
	
	Если Параметры.Свойство("КБК") Тогда
		ВходящийКБК         = Сред(Параметры.КБК, 4);
		АдминистраторДохода = Лев(Параметры.КБК,  3);
		ВидДохода           = Сред(Параметры.КБК, 4, 10);
		ПодВидДохода        = Сред(Параметры.КБК, 14, 4);
		КОСГУ               = Сред(Параметры.КБК, 18);
	КонецЕсли;
	
	ДатаАктуальностиКлассификатора = Справочники.ВидыНалоговИПлатежейВБюджет.ДатаАктуальностиКлассификатора();
	ГодАктуальностиКлассификатора  = Год(ДатаАктуальностиКлассификатора);
	Если Параметры.Свойство("ГодПлатежа") Тогда
		ГодПлатежа = ?(Параметры.ГодПлатежа < ГодАктуальностиКлассификатора,
			Год(ДатаАктуальностиКлассификатора - 1), ГодАктуальностиКлассификатора);
	Иначе
		ГодПлатежа = ГодАктуальностиКлассификатора;
	КонецЕсли;
	
	Если Параметры.Свойство("ПоказательТипа") Тогда
		ПоказательТипа = Параметры.ПоказательТипа;
	КонецЕсли;
	
	СоздатьСоответствиеВидаИПодвидаДоходаДляСтраховыхВзносов();
	
	ПодобратьНаименованиеКБК(ЭтотОбъект, ВходящийКБК);
	ЗаполнитьСписокПодвидаДохода(ЭтотОбъект);
	
	Если СтрДлина(ВидДохода) = 10 Тогда
		ПодвидДохода = ОпределениеПодвидаДохода(ПодвидДохода, ПоказательТипа, ВидПеречисления,
			ВидДохода, ВидИПодвидДоходаИсключения);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьСоответствиеВидаИПодвидаДоходаДляСтраховыхВзносов()
	
	ВидИПодвидДоходаИсключения = Новый Структура();
	
	// Страховые взносы на обязательное медицинское страхование работающего населения,
	// зачисляемые в бюджет Федерального фонда обязательного медицинского страхования
	СтраховыеВзносы           = Новый Соответствие;
	ПениПоСтраховыеВзносы     = Новый Соответствие;
	ПроцентыПоСтраховыеВзносы = Новый Соответствие;
	ШтрафыПоСтраховыеВзносы   = Новый Соответствие;
	Если ГодПлатежа < Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа2017_90н()) Тогда
		СтраховыеВзносы.Вставить("1011",
			НСтр("ru = '1011 - страховые взносы до 2017 г. на обязательное медицинское страхование (ОМС)'"));
		ПениПоСтраховыеВзносы.Вставить("2011",
			НСтр("ru = '2011 - пени и проценты по страховым взносам до 2017 г. на обязательное медицинское страхование (ОМС)'"));
		ШтрафыПоСтраховыеВзносы.Вставить("3011",
			НСтр("ru = '3011 - штрафы по страховым взносам до 2017 г. на обязательное медицинское страхование (ОМС)'"));
	Иначе
		СтраховыеВзносы.Вставить("1013",
			НСтр("ru = '1013 - страховые взносы с 2017 г. на обязательное медицинское страхование (ОМС)'"));
		ПениПоСтраховыеВзносы.Вставить("2013",
			НСтр("ru = '2013 - пени по страховым взносам с 2017 г. на обязательное медицинское страхование (ОМС)'"));
		ПроцентыПоСтраховыеВзносы.Вставить("2213",
			НСтр("ru = '2213 - проценты по страховым взносам с 2017 г. на обязательное медицинское страхование (ОМС)'"));
		ШтрафыПоСтраховыеВзносы.Вставить("3013",
			НСтр("ru = '3013 - штрафы по страховым взносам с 2017 г. на обязательное медицинское страхование (ОМС)'"));
	КонецЕсли;
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(СтраховыеВзносы);
	ПодвидыДохода.Добавить(ПениПоСтраховыеВзносы);
	Если ГодПлатежа >= Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа90н()) Тогда
		ПодвидыДохода.Добавить(ПроцентыПоСтраховыеВзносы);
	КонецЕсли;
	ПодвидыДохода.Добавить(ШтрафыПоСтраховыеВзносы);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020210108", ПодвидыДохода); // за работников
	
	// Дополнительные страховые взносы на накопительную часть трудовой пенсии, зачисляемые в Пенсионный фонд Российской Федерации
	ДопВзносыСамостоятельно = Новый Соответствие;
	ДопВзносыСамостоятельно.Вставить("1100",
		НСтр("ru = '1100 - дополнительные страховые взносы на накопительную часть трудовой пенсии (для лиц уплачивающих самостоятельно)'"));
	ДопВзносыРаботодатель   = Новый Соответствие;
	ДопВзносыРаботодатель.Вставить("1200",
		НСтр("ru = '1200 - дополнительные страховые взносы на накопительную часть трудовой пенсии (софинансирование работодателем)'"));
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(ДопВзносыСамостоятельно);
	ПодвидыДохода.Добавить(ДопВзносыРаботодатель);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020204106", ПодвидыДохода);
	
	// Фиксированные взносы в ФСС
	ФиксированныеВзносыФСС = Новый Соответствие;
	ФиксированныеВзносыФСС.Вставить("6000",
		НСтр("ru = '6000 - фиксированные взносы в Фонд социального страхования'"));
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(ФиксированныеВзносыФСС);
	ВидИПодвидДоходаИсключения.Вставить("ВД1170602007", ПодвидыДохода);
	
	СтраховыеВзносыДо2012 = Новый Соответствие;
	СтраховыеВзносыДо2012.Вставить("1012",
		НСтр("ru = '1012 - страховые взносы на обязательное медицинское страхование (ОМС) за себя до 2012 года'"));
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(СтраховыеВзносы);
	Если ГодПлатежа < Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа2017_90н()) Тогда
		ПодвидыДохода.Добавить(СтраховыеВзносыДо2012);
	КонецЕсли;
	ПодвидыДохода.Добавить(ПениПоСтраховыеВзносы);
	ПодвидыДохода.Добавить(ШтрафыПоСтраховыеВзносы);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020210308", ПодвидыДохода); // за себя
	
	// Страховые взносы на ОПС на выплату страховой пенсии.
	ВзносыНаОПССтраховая           = Новый Соответствие;
	ПениНаВзносыНаОПССтраховая     = Новый Соответствие;
	ПроцентыНаВзносыНаОПССтраховая = Новый Соответствие;
	ШтрафыНаВзносыНаОПССтраховая   = Новый Соответствие;
	Если ГодПлатежа < Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа2017_90н()) Тогда
		ВзносыНаОПССтраховая.Вставить("1000",
			НСтр("ru = '1000 - страховые взносы до 2017 г. на ОПС на выплату страховой пенсии'"));
		ПениНаВзносыНаОПССтраховая.Вставить("2100",
			НСтр("ru = '2100 - пени по страховым взносам до 2017 г. на ОПС на выплату страховой пенсии'"));
		ПроцентыНаВзносыНаОПССтраховая.Вставить("2200",
			НСтр("ru = '2200 - проценты по страховым взносам до 2017 г. на ОПС на выплату страховой пенсии'"));
		ШтрафыНаВзносыНаОПССтраховая.Вставить("3000",
			НСтр("ru = '3000 - штрафы по страховым взносам до 2017 г. на ОПС на выплату страховой пенсии'"));
	Иначе
		ВзносыНаОПССтраховая.Вставить("1010",
			НСтр("ru = '1010 - страховые взносы с 2017 г. на ОПС на выплату страховой пенсии'"));
		ПениНаВзносыНаОПССтраховая.Вставить("2110",
			НСтр("ru = '2110 - пени по страховым взносам с 2017 г. на ОПС на выплату страховой пенсии'"));
		ПроцентыНаВзносыНаОПССтраховая.Вставить("2210",
			НСтр("ru = '2210 - проценты по страховым взносам с 2017 г. на ОПС на выплату страховой пенсии'"));
		ШтрафыНаВзносыНаОПССтраховая.Вставить("3010",
			НСтр("ru = '3010 - штрафы по страховым взносам с 2017 г. на ОПС на выплату страховой пенсии'"));
	КонецЕсли;
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(ВзносыНаОПССтраховая);
	ПодвидыДохода.Добавить(ПениНаВзносыНаОПССтраховая);
	ПодвидыДохода.Добавить(ПроцентыНаВзносыНаОПССтраховая);
	ПодвидыДохода.Добавить(ШтрафыНаВзносыНаОПССтраховая);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020201006", ПодвидыДохода);
	
	// Страховые взносы на ОПС в фиксированном размере на выплату страховой пенсии - они разбиваются на:
	//  - исчисленные с суммы дохода плательщика, не превышающие предельной величины дохода;
	//  - исчисленные с суммы дохода плательщика, полученной сверх предельной величины дохода.
	ВзносыНаОПСвФиксированномРазмереДо         = Новый Соответствие;
	ВзносыНаОПСвФиксированномРазмереСверх      = Новый Соответствие;
	ПениНаВзносыНаОПСвФиксированномРазмере     = Новый Соответствие;
	ПроцентыНаВзносыНаОПСвФиксированномРазмере = Новый Соответствие;
	ШтрафыНаВзносыНаОПСвФиксированномРазмере   = Новый Соответствие;
	Если ГодПлатежа < Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа2017_90н()) Тогда
		ВзносыНаОПСвФиксированномРазмереДо.Вставить("1100",
			НСтр("ru = '1100 - страховые взносы на ОПС в фиксированном размере до 2017 г., исчисленные с суммы дохода, не превышающие предела'"));
		ВзносыНаОПСвФиксированномРазмереСверх.Вставить("1200",
			НСтр("ru = '1200 - страховые взносы на ОПС в фиксированном размере до 2017 г., исчисленные с суммы дохода, полученной сверх предела'"));
		ПениНаВзносыНаОПСвФиксированномРазмере.Вставить("2100",
			НСтр("ru = '2100 - пени по страховым взносам на ОПС в фиксированном размере до 2017 г. на выплату страховой пенсии'"));
		ПроцентыНаВзносыНаОПСвФиксированномРазмере.Вставить("2200",
			НСтр("ru = '2200 - проценты по страховым взносам на ОПС в фиксированном размере до 2017 г. на выплату страховой пенсии'"));
		ШтрафыНаВзносыНаОПСвФиксированномРазмере.Вставить("3000",
			НСтр("ru = '3000 - штрафы по страховым взносам на ОПС в фиксированном размере до 2017 г. на выплату страховой пенсии'"));
	Иначе
		ВзносыНаОПСвФиксированномРазмереДо.Вставить("1110",
			НСтр("ru = '1110 - страховые взносы на ОПС в фиксированном размере с 2017 г.'"));
		ПениНаВзносыНаОПСвФиксированномРазмере.Вставить("2110",
			НСтр("ru = '2110 - пени по страховым взносам на ОПС в фиксированном размере с 2017 г. на выплату страховой пенсии'"));
		ПроцентыНаВзносыНаОПСвФиксированномРазмере.Вставить("2210",
			НСтр("ru = '2210 - проценты по страховым взносам на ОПС в фиксированном размере с 2017 г. на выплату страховой пенсии'"));
		ШтрафыНаВзносыНаОПСвФиксированномРазмере.Вставить("3010",
			НСтр("ru = '3010 - штрафы по страховым взносам на ОПС в фиксированном размере с 2017 г. на выплату страховой пенсии'"));
	КонецЕсли;
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(ВзносыНаОПСвФиксированномРазмереДо);
	ПодвидыДохода.Добавить(ВзносыНаОПСвФиксированномРазмереСверх);
	ПодвидыДохода.Добавить(ПениНаВзносыНаОПСвФиксированномРазмере);
	ПодвидыДохода.Добавить(ПроцентыНаВзносыНаОПСвФиксированномРазмере);
	ПодвидыДохода.Добавить(ШтрафыНаВзносыНаОПСвФиксированномРазмере);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020214006", ПодвидыДохода);
	
	СтраховыеВзносыВФСС           = Новый Соответствие;
	ПениНаСтраховыеВзносыВФСС     = Новый Соответствие;
	ПроцентыНаСтраховыеВзносыВФСС = Новый Соответствие;
	ШтрафыНаСтраховыеВзносыВФСС   = Новый Соответствие;
	Если ГодПлатежа < Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа2017_90н()) Тогда
		// Страховые взносы в ФСС
		СтраховыеВзносыВФСС.Вставить("1000",
			НСтр("ru = '1000 - страховые взносы до 2017 г. в ФСС'"));
		ПениНаСтраховыеВзносыВФСС.Вставить("2100",
			НСтр("ru = '2100 - пени по страховым взносам до 2017 г. в ФСС'"));
		ПроцентыНаСтраховыеВзносыВФСС.Вставить("2200",
			НСтр("ru = '2200 - проценты по страховым взносам до 2017 г. на обязательное социальное страхование'"));
		ШтрафыНаСтраховыеВзносыВФСС.Вставить("3000",
			НСтр("ru = '3000 - штрафы по страховым взносам до 2017 г. в ФСС'"));
	Иначе
		// Страховые взносы
		СтраховыеВзносыВФСС.Вставить("1010",
			НСтр("ru = '1010 - страховые взносы с 2017 г. на обязательное социальное страхование'"));
		ПениНаСтраховыеВзносыВФСС.Вставить("2110",
			НСтр("ru = '2110 - пени по страховым взносам с 2017 г. на обязательное социальное страхование'"));
		ПроцентыНаСтраховыеВзносыВФСС.Вставить("2210",
			НСтр("ru = '2210 - проценты по страховым взносам с 2017 г. на обязательное социальное страхование'"));
		ШтрафыНаСтраховыеВзносыВФСС.Вставить("3010",
			НСтр("ru = '3010 - штрафы по страховым взносам с 2017 г. на обязательное социальное страхование'"));
	КонецЕсли;
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(СтраховыеВзносыВФСС);
	ПодвидыДохода.Добавить(ПениНаСтраховыеВзносыВФСС);
	ПодвидыДохода.Добавить(ПроцентыНаСтраховыеВзносыВФСС);
	ПодвидыДохода.Добавить(ШтрафыНаСтраховыеВзносыВФСС);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020209007", ПодвидыДохода);
	
	// Страховые взносы в ФСС от несчастных случаев
	ВзносыНаСтраховыеВзносыВФССНС           = Новый Соответствие;
	ВзносыНаСтраховыеВзносыВФССНС.Вставить("1000",
		НСтр("ru = '1000 - страховые взносы в ФСС от несчастных случаев'"));
	ПениНаВзносыНаСтраховыеВзносыВФССНС     = Новый Соответствие;
	ПениНаВзносыНаСтраховыеВзносыВФССНС.Вставить("2100",
		НСтр("ru = '2100 - пени по страховым взносам в ФСС от несчастных случаев'"));
	ПроцентыНаВзносыНаСтраховыеВзносыВФССНС     = Новый Соответствие;
	ПроцентыНаВзносыНаСтраховыеВзносыВФССНС.Вставить("2200",
		НСтр("ru = '2200 - проценты по страховым взносам в ФСС от несчастных случаев'"));
	ШтрафыНаВзносыНаСтраховыеВзносыВФССНС   = Новый Соответствие;
	ШтрафыНаВзносыНаСтраховыеВзносыВФССНС.Вставить("3000",
		НСтр("ru = '3000 - штрафы по страховым взносам в ФСС от несчастных случаев'"));
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(ВзносыНаСтраховыеВзносыВФССНС);
	ПодвидыДохода.Добавить(ПениНаВзносыНаСтраховыеВзносыВФССНС);
	ПодвидыДохода.Добавить(ПроцентыНаВзносыНаСтраховыеВзносыВФССНС);
	ПодвидыДохода.Добавить(ШтрафыНаВзносыНаСтраховыеВзносыВФССНС);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020205007", ПодвидыДохода);
	
	// Страховые взносы по доп.тарифу за вредные условия труда
	СтраховыйВзносыВредныеУсловия = Новый Соответствие;
	СтраховыйВзносыВредныеУсловия.Вставить("1010",
		НСтр("ru = '1010 - Страховые взносы по доп.тарифу за вредные условия труда (не зависит от специальной оценки)'"));
	СтраховыйВзносыВредныеУсловияСпецОценка = Новый Соответствие;
	СтраховыйВзносыВредныеУсловияСпецОценка.Вставить("1020",
		НСтр("ru = '1020 - Страховые взносы по доп.тарифу за вредные условия труда (зависит от специальной оценки)'"));
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(СтраховыйВзносыВредныеУсловияСпецОценка);
	ПодвидыДохода.Добавить(СтраховыйВзносыВредныеУсловия);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020213106", ПодвидыДохода);
	ВидИПодвидДоходаИсключения.Вставить("ВД1020213206", ПодвидыДохода);
	
	// Авансовые платежи в счет будущих таможенных и иных платежей
	// Страховые взносы в ФСС от несчастных случаев
	АвансовыеТаможенныеПлатежи = Новый Соответствие;
	АвансовыеТаможенныеПлатежи.Вставить("0000",
		НСтр("ru = '0000 - авансовые платежи в счет будущих таможенных и иных платежей'"));
	ПодвидыДохода = Новый Массив;
	ПодвидыДохода.Добавить(АвансовыеТаможенныеПлатежи);
	ВидИПодвидДоходаИсключения.Вставить("ВД1100900001", ПодвидыДохода);
	
	УтилизационныйСборТаможенныеПлатежи = Новый Соответствие;
	УтилизационныйСборТаможенныеПлатежи.Вставить("1000",
		НСтр("ru = '1000 - утилизационный сбор за ввозимые (кроме Республики Беларусь) колесные транспортные средства (шасси)'"));
	УтилизационныйСборТаможенныеПлатежи.Вставить("1010",
		НСтр("ru = '1010 - пени за просрочку уплаты утилизационного сбора за ввозимые (кроме Республики Беларусь) колесные транспортные средства (шасси)'"));
	УтилизационныйСборТаможенныеПлатежи.Вставить("3000",
		НСтр("ru = '3000 - утилизационный сбор за ввозимые из Республики Беларусь колесные транспортные средства (шасси)'"));
	УтилизационныйСборТаможенныеПлатежи.Вставить("3010",
		НСтр("ru = '3010 - пени за просрочку уплаты утилизационного сбора за ввозимые из Республики Беларусь самоходные машины и прицепы к ним'"));
	УтилизационныйСборТаможенныеПлатежи.Вставить("5000",
		НСтр("ru = '5000 - утилизационный сбор за ввозимые (кроме Республики Беларусь) самоходные машины и прицепы к ним'"));
	УтилизационныйСборТаможенныеПлатежи.Вставить("7000",
		НСтр("ru = '7000 - утилизационный сбор за ввозимые из Республики Беларусь самоходные машины и прицепы к ним'"));
	
	УтилизационныйСборНалоговыеПлатежи = Новый Соответствие;
	УтилизационныйСборНалоговыеПлатежи.Вставить("2000",
		НСтр("ru = '2000 - утилизационный сбор за колесные транспортные средства (шасси)'"));
	УтилизационныйСборНалоговыеПлатежи.Вставить("6000",
		НСтр("ru = '6000 - утилизационный сбор за самоходные машины и прицепы к ним'"));
	
	ПодвидыДохода = Новый Массив;
	Если АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияФТС() Тогда
		ПодвидыДохода.Добавить(УтилизационныйСборТаможенныеПлатежи);
		ВидИПодвидДоходаИсключения.Вставить("ВД1120800001", ПодвидыДохода);
	ИначеЕсли АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияНалоговымиОрганами() Тогда
		ПодвидыДохода.Добавить(УтилизационныйСборНалоговыеПлатежи);
		ВидИПодвидДоходаИсключения.Вставить("ВД1120800001", ПодвидыДохода);
	Иначе
		ПодвидыДохода.Добавить(УтилизационныйСборНалоговыеПлатежи);
		ПодвидыДохода.Добавить(УтилизационныйСборТаможенныеПлатежи);
		ВидИПодвидДоходаИсключения.Вставить("ВД1120800001", ПодвидыДохода);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЗавершениеРаботы И Модифицированность Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Если Модифицированность Тогда
		
		СтандартнаяОбработка = Ложь;
		Отказ = Истина;
		
		ТекстВопроса = НСтр("ru = 'КБК был изменен, сохранить?'");
		
		Оповещение = Новый ОписаниеОповещения("ВопросСохраненияКБКЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНетОтмена,, КодВозвратаДиалога.Да);
		
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ШАПКИ ФОРМЫ

&НаКлиенте
Процедура АдминистраторДоходаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ИмяМакета",    "АдминистраторыДоходовБюджетов");
	СтруктураПараметров.Вставить("СтрокаПоиска", АдминистраторДохода);
	СтруктураПараметров.Вставить("Заголовок",    НСтр("ru = 'Разряды 1-3 (код администратора поступлений)'"));
	СтруктураПараметров.Вставить("ГодПлатежа",   ГодПлатежа);
	ОткрытьФорму("Справочник.ВидыНалоговИПлатежейВБюджет.Форма.ФормаВыбораКодаИзКлассификатора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура АдминистраторДоходаПриИзменении(Элемент)
	
	АдминистраторДоходаПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура АдминистраторДоходаПриИзмененииНаСервере()
	
	ВидПеречисления = ПлатежиВБюджетКлиентСервер.ВидПеречисления(
		АдминистраторДохода + "00000000000000000", Дата(ГодПлатежа, 1, 1));
	
	ПодобратьНаименованиеКБК(ЭтотОбъект);
	СоздатьСоответствиеВидаИПодвидаДоходаДляСтраховыхВзносов();
	ЗаполнитьСписокПодвидаДохода(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидДоходаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка  = Ложь;
	
	СтруктураПараметров   = Новый Структура;
	СтруктураПараметров.Вставить("ИмяМакета", "КлассификацияДоходовБюджетов");
	СтатьяДоходаДляПоиска = ?(ПустаяСтрока(ВидДохода), "",
		ВидДохода + ?(СтрДлина(ВидДохода) = 10,
			?(ПустаяСтрока(ПодвидДохода) ИЛИ СтрДлина(ПодвидДохода) < 4, "0000",
				ПодвидДохода)
			+ КОСГУ, ""));
	СтруктураПараметров.Вставить("СтрокаПоиска",        СтатьяДоходаДляПоиска);
	СтруктураПараметров.Вставить("КБКИсходный",         ВходящийКБК);
	СтруктураПараметров.Вставить("АдминистраторДохода", АдминистраторДохода);
	СтруктураПараметров.Вставить("Заголовок",           НСтр("ru = 'Разряды 4-20'"));
	СтруктураПараметров.Вставить("ГодПлатежа",          ГодПлатежа);
	ОткрытьФорму("Справочник.ВидыНалоговИПлатежейВБюджет.Форма.ФормаВыбораКодаИзКлассификатора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидДоходаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ВходящийКБК            = ВыбранноеЗначение;
	СтатьяДоходаДляПоиска  = ВидДохода + "0000" + КОСГУ;
	Если ВыбранноеЗначение = СтатьяДоходаДляПоиска Тогда
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
	ВидДохода = Лев(ВыбранноеЗначение, 10);
	
	ВыбраныйПодвидДохода = Сред(СтрЗаменить(ВыбранноеЗначение, " ", ""), 11, 4);
	Если НЕ ПустаяСтрока(ВыбраныйПодвидДохода) И ВыбраныйПодвидДохода <> "0000"
		И СтрДлина(ВыбраныйПодвидДохода) = 4 И СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(ВыбраныйПодвидДохода) Тогда
		ПодвидДохода = ВыбраныйПодвидДохода;
	КонецЕсли;
	
	Если ПустаяСтрока(ПодвидДохода) ИЛИ ПодвидДохода = "0000" Тогда
		Если НЕ ПустаяСтрока(ПоказательТипа) Тогда
			ПодвидДохода = ОпределениеПодвидаДохода(ПодвидДохода, ПоказательТипа, ВидПеречисления,
				ВидДохода, ВидИПодвидДоходаИсключения);
		Иначе
			// По умолчанию подставляем подвид "Налог" с кодом 1000
			ПодвидДохода = "1000";
		КонецЕсли;
	КонецЕсли;
	
	КОСГУ = Сред(ВыбранноеЗначение, 15);
	
	ИзменениеВидаДохода(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидДоходаПриИзменении(Элемент)
	
	ВидДохода = СтрЗаменить(ВидДохода, " ", "");
	ИзменениеВидаДохода(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменениеВидаДохода(ОпределитьКОСГУ)
	
	Если ВидИПодвидДоходаИсключения.Свойство("ВД" + ВидДохода)
		И ВидПеречисления <> ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ТаможенныйПлатеж") Тогда
		Если ПлатежиВБюджетКлиентСервер.ДействуетНовыйАдмиинстраторСтраховыхВзносов(РабочаяДата) ИЛИ
			ГодПлатежа >= Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа2017_90н()) Тогда
			Если ВидДохода = "1020205007" Тогда
				АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияПенсионнымФондом();
				ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ИнойПлатеж");
			Иначе
				АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияНалоговымиОрганами();
				ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.НалоговыйПлатеж");
			КонецЕсли;
		Иначе
			Если ВидДохода = "1170602007" И АдминистраторДохода <> ПлатежиВБюджетКлиентСервер.КодАдминистрированияФСС() Тогда
				АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияФСС();
			ИначеЕсли АдминистраторДохода <> ПлатежиВБюджетКлиентСервер.КодАдминистрированияПенсионнымФондом() Тогда
				АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияПенсионнымФондом();
			КонецЕсли;
			
			ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ИнойПлатеж");
		КонецЕсли;
	КонецЕсли;
	
	ПодобратьНаименованиеКБК(ЭтотОбъект,, ОпределитьКОСГУ);
	ЗаполнитьСписокПодвидаДохода(ЭтотОбъект);
	
	Если СтрДлина(ВидДохода) = 10 Тогда
		Если ВидИПодвидДоходаИсключения.Свойство("ВД" + ВидДохода) И ВидИПодвидДоходаИсключения["ВД" + ВидДохода].Количество() > 0 Тогда
			Для каждого КлючИЗначение Из ВидИПодвидДоходаИсключения["ВД" + ВидДохода][0] Цикл
				ПодвидДохода = КлючИЗначение.Ключ;
				Прервать;
			КонецЦикла;
		ИначеЕсли НЕ ПустаяСтрока(ПоказательТипа) Тогда // Неактуально с 01.01.2015.
			ПодвидДохода = ОпределениеПодвидаДохода(ПодвидДохода, ПоказательТипа, ВидПеречисления,
				ВидДохода, ВидИПодвидДоходаИсключения);
		Иначе
			ПодвидДохода = "1000";
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодвидДоходаПриИзменении(Элемент)
	
	Если ПустаяСтрока(КОСГУ) Тогда
		ПодобратьНаименованиеКБК(ЭтотОбъект,, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КОСГУПриИзменении(Элемент)
	
	ПодобратьНаименованиеКБК(ЭтотОбъект);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

&НаКлиенте
Процедура ОК(Команда)
	
	Если НЕ ЕстьОшибкиЗаполненияРеквизитов() Тогда
		
		Модифицированность = Ложь;
		ОповеститьОВыборе(ПолучитьКБК());
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	Модифицированность = Ложь;
	Закрыть();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаКлиентеНаСервереБезКонтекста
Функция ОпределениеПодвидаДохода(Знач ПодвидДохода, Знач ПоказательТипа, Знач ВидПеречисления,
		Знач ВидДохода, Знач ВидИПодвидДоходаИсключения)
	Перем СписокПодвидовДляСтраховых;
	
	// По умолчанию подставляем подвид "Налог" с кодом 1000 для всех случаев, где нет исключений
	
	ПодвидДохода = ?(ПустаяСтрока(ПодвидДохода), "0000", ПодвидДохода);
	ОкончаниеПодвидаДохода = Сред(ПодвидДохода, 2);
	
	КодИсключение = Ложь;
	Если ВидИПодвидДоходаИсключения.Свойство("ВД" + ВидДохода, СписокПодвидовДляСтраховых) Тогда
		ВходитВСписок = Ложь;
		Для каждого ПодвидДоходаИзСтруктуры Из СписокПодвидовДляСтраховых Цикл
			Для каждого КлючиИЗначениеПодвидДохода Из ПодвидДоходаИзСтруктуры Цикл
				Если ПодвидДохода = КлючиИЗначениеПодвидДохода.Ключ Тогда
					ВходитВСписок = Истина;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		
		Если НЕ ВходитВСписок Тогда
			ПодвидДоходаИзСтруктуры = СписокПодвидовДляСтраховых[0];
			Для каждого КлючиИЗначениеПодвидДохода Из ПодвидДоходаИзСтруктуры Цикл
				ПодвидДохода = КлючиИЗначениеПодвидДохода.Ключ;
			КонецЦикла;
		КонецЕсли;
		
		КодИсключение = Лев(ОкончаниеПодвидаДохода, 1) = "1" ИЛИ Лев(ОкончаниеПодвидаДохода, 1) = "2";
	ИначеЕсли ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.НалоговыйПлатеж") Тогда
		КодИсключение = Лев(ПодвидДохода, 0) = "0" И Число(Лев(ОкончаниеПодвидаДохода, 1)) > 2 И Число(Сред(ОкончаниеПодвидаДохода, 2, 1)) > 2
			ИЛИ Число(Лев(ПодвидДохода, 1)) > 4;
		Если НЕ КодИсключение Тогда
			ПодвидДохода = "1000";
		КонецЕсли;
	ИначеЕсли ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ТаможенныйПлатеж") Тогда
		КодИсключение = Лев(ПодвидДохода, 1) = "0";
		Если НЕ КодИсключение Тогда
			ПодвидДохода = "1000";
		КонецЕсли;
	ИначеЕсли ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ИнойПлатеж") Тогда
		КодИсключение = Число(Лев(ПодвидДохода, 1)) > 5;
		Если НЕ КодИсключение Тогда
			ПодвидДохода = "1000";
		КонецЕсли;
	КонецЕсли;
	
	Если КодИсключение Тогда
		Возврат ПодвидДохода;
	КонецЕсли;
	
	ОкончаниеПодвидаДохода = Сред(ПодвидДохода, 2);
	
	Если НЕ ПустаяСтрока(ПоказательТипа) Тогда // с 2015 г. не используется
		Если ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.НалоговыйПлатеж")
			И (ПоказательТипа = "0" // с 2014 г.
			ИЛИ ПоказательТипа = "НС" ИЛИ ПоказательТипа = "АВ") // до 2014 г.
			ИЛИ ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ТаможенныйПлатеж")
			И (ПоказательТипа = "0" ИЛИ ПоказательТипа = "ЗД") Тогда
			ПодвидДохода = "1" + ОкончаниеПодвидаДохода;
		ИначеЕсли ПоказательТипа = "ПЕ" ИЛИ ПоказательТипа = "ПЦ" Тогда
			ПодвидДохода = "2" + ОкончаниеПодвидаДохода;
		ИначеЕсли ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.НалоговыйПлатеж")
			И (ПоказательТипа = "АШ" ИЛИ ПоказательТипа = "СА") // до 2014 г.
			ИЛИ ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ТаможенныйПлатеж") И ПоказательТипа = "ШТ" Тогда
			ПодвидДохода = "3" + ОкончаниеПодвидаДохода;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ПодвидДохода;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьСписокПодвидаДохода(Форма)
	
	Элементы = Форма.Элементы;
	
	Если ПустаяСтрока(Форма.АдминистраторДохода) Тогда
		ПлатежАдминистрируетсяНалоговымиОрганами =
			Форма.ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.НалоговыйПлатеж");
		ПлатежАдминистрируетсяТаможеннымиОрганами =
			Форма.ВидПеречисления = ПредопределенноеЗначение("Перечисление.ВидыПеречисленийВБюджет.ТаможенныйПлатеж");
	Иначе
		ПлатежАдминистрируетсяНалоговымиОрганами =
			Форма.АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияНалоговымиОрганами();
		ПлатежАдминистрируетсяТаможеннымиОрганами =
			Форма.АдминистраторДохода = ПлатежиВБюджетКлиентСервер.КодАдминистрированияФТС();
	КонецЕсли;
	
	Элементы.ПодвидДохода.СписокВыбора.Очистить();
	Если Форма.ВидИПодвидДоходаИсключения.Свойство("ВД" + Форма.ВидДохода) Тогда
		Для каждого ПодвидДохода Из Форма.ВидИПодвидДоходаИсключения["ВД" + Форма.ВидДохода] Цикл
			Для каждого КлючиИЗначениеПодвидДохода Из ПодвидДохода Цикл
				Элементы.ПодвидДохода.СписокВыбора.Добавить(КлючиИЗначениеПодвидДохода.Ключ, КлючиИЗначениеПодвидДохода.Значение);
			КонецЦикла;
		КонецЦикла;
		Элементы.ПодвидДохода.СписокВыбора.СортироватьПоЗначению();
	ИначеЕсли ПлатежАдминистрируетсяНалоговымиОрганами Тогда
		Элементы.ПодвидДохода.СписокВыбора.Добавить("1000",
			НСтр("ru = '1000 - сумма налога (взноса)'"));
		Если Форма.ГодПлатежа < Год(ПлатежиВБюджетКлиентСервер.НачалоДействияПриказа126н()) Тогда
			Элементы.ПодвидДохода.СписокВыбора.Добавить("2000",
				НСтр("ru = '2000 - пени и проценты по налогу (взносу)'"));
		Иначе
			Элементы.ПодвидДохода.СписокВыбора.Добавить("2100",
				НСтр("ru = '2100 - пени по налогу (взносу)'"));
			Элементы.ПодвидДохода.СписокВыбора.Добавить("2200",
				НСтр("ru = '2200 - проценты по налогу (взносу)'"));
		КонецЕсли;
		Элементы.ПодвидДохода.СписокВыбора.Добавить("3000",
			НСтр("ru = '3000 - суммы штрафов по налогу (взносу)'"));
	ИначеЕсли ПлатежАдминистрируетсяТаможеннымиОрганами Тогда
		Элементы.ПодвидДохода.СписокВыбора.Добавить("0000",
			НСтр("ru = '0000 - сумма авансового платежа'"));
		Элементы.ПодвидДохода.СписокВыбора.Добавить("1000",
			НСтр("ru = '1000 - сумма платежа'"));
		Элементы.ПодвидДохода.СписокВыбора.Добавить("2000",
			НСтр("ru = '2000 - пени и проценты по соответствующему платежу'"));
		Элементы.ПодвидДохода.СписокВыбора.Добавить("3000",
			НСтр("ru = '3000 - суммы денежных взысканий (штрафов) по соответствующему платежу'"));;
		Элементы.ПодвидДохода.СписокВыбора.Добавить("5000",
			НСтр("ru = '5000 - уплата процентов, начисленных на суммы излишне взысканных (уплаченных) платежей, а также при нарушении сроков их возврата'"));
	Иначе
		Элементы.ПодвидДохода.СписокВыбора.Добавить("1000",
			НСтр("ru = '1000 - сумма взноса'"));
		Элементы.ПодвидДохода.СписокВыбора.Добавить("2000",
			НСтр("ru = '2000 - пени и проценты по взносу'"));
		Элементы.ПодвидДохода.СписокВыбора.Добавить("3000",
			НСтр("ru = '3000 - суммы штрафов по взносу'"));
		Элементы.ПодвидДохода.СписокВыбора.Добавить("6000",
			НСтр("ru = '6000 - суммы и штрафы в федеральные государственные органы, внебюджетные фонды, Банк России'"));
	КонецЕсли;
	
	Элементы.ПодвидДохода.СписокВыбора.Добавить("", НСтр("ru = '<указать вручную>'"));
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьКБК()
	
	Возврат АдминистраторДохода + ВидДохода + ПодвидДохода + КОСГУ;
	
КонецФункции

&НаКлиенте
Функция ЕстьОшибкиЗаполненияРеквизитов()
	
	ЕстьОшибки = Ложь;
	
	ОчиститьСообщения();
	
	Если ПустаяСтрока(АдминистраторДохода) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Заполнение", НСтр("ru = 'Разряды 1-3'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "АдминистраторДохода");
		ЕстьОшибки = Истина;
	ИначеЕсли СтрДлина(АдминистраторДохода) <> 3 Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Корректность", НСтр("ru = 'Разряды 1-3'"),,,
			НСтр("ru = 'Поле должно состоять из 3 знаков'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "АдминистраторДохода");
		ЕстьОшибки = Истина;
	КонецЕсли;
	
	Если ПустаяСтрока(ВидДохода) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Заполнение", НСтр("ru = 'Разряды 4-13'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "ВидДохода");
		ЕстьОшибки = Истина;
	ИначеЕсли СтрДлина(ВидДохода) <> 10 Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Корректность", НСтр("ru = 'Разряды 4-13'"),,,
			НСтр("ru = 'Поле должно состоять из 10 знаков'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "ВидДохода");
		ЕстьОшибки = Истина;
	КонецЕсли;
	
	Если ПустаяСтрока(ПодвидДохода) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Заполнение", НСтр("ru = 'Разряды 14-17'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "ПодвидДохода");
		ЕстьОшибки = Истина;
	ИначеЕсли СтрДлина(ПодвидДохода) <> 4 Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Корректность", НСтр("ru = 'Разряды 14-17'"),,,
			НСтр("ru = 'Поле должно состоять из 4 знаков'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "ПодвидДохода");
		ЕстьОшибки = Истина;
	КонецЕсли;
	
	Если ПустаяСтрока(КОСГУ) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Заполнение", НСтр("ru = 'Разряды 18-20'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "КОСГУ");
		ЕстьОшибки = Истина;
	ИначеЕсли СтрДлина(КОСГУ) <> 3 Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Поле", "Корректность", НСтр("ru = 'Разряды 18-20'"),,,
			НСтр("ru = 'Поле должно состоять из 3 знаков'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "КОСГУ");
		ЕстьОшибки = Истина;
	КонецЕсли;
	
	Возврат ЕстьОшибки;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ПодобратьНаименованиеКБК(Форма, КБКИсходный = "", ОпределитьКОСГУ = Ложь)
	
	Если СтрДлина(Форма.ВидДохода) < 10 Тогда
		Форма.НаименованиеКБК = "";
		Возврат;
	КонецЕсли;
	
	КБК = Форма.ВидДохода + "0000" + Форма.КОСГУ;
	Если КБКИсходный = "" Тогда
		КБКИсходный = Форма.ВидДохода + Форма.ПодвидДохода + Форма.КОСГУ;
	КонецЕсли;
	
	КодДоходаБюджета = НайтиКодДоходаБюджета(КБК, Форма.ГодПлатежа, КБКИсходный, ОпределитьКОСГУ);
	
	Форма.КОСГУ = КодДоходаБюджета.КОСГУ;
	Форма.НаименованиеКБК = КодДоходаБюджета.Наименование;
	
	Если НЕ ПустаяСтрока(КодДоходаБюджета.ПодвидДохода) Тогда
		Форма.ПодвидДохода = КодДоходаБюджета.ПодвидДохода;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НайтиКодДоходаБюджета(СтрокаПоиска, ГодПлатежа, КБКИсходный, ОпределитьКОСГУ)
	
	Возврат Справочники.ВидыНалоговИПлатежейВБюджет.НайтиКодДоходаБюджета(СтрокаПоиска, ГодПлатежа, КБКИсходный, ОпределитьКОСГУ);
	
КонецФункции

&НаКлиенте
Процедура ВопросСохраненияКБКЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		
		Если НЕ ЕстьОшибкиЗаполненияРеквизитов() Тогда
			
			Модифицированность = Ложь;
			ОповеститьОВыборе(ПолучитьКБК());
			
		КонецЕсли;
		
	ИначеЕсли Результат = КодВозвратаДиалога.Нет Тогда
		
		Модифицированность = Ложь;
		Закрыть();
		
	КонецЕсли;
	
КонецПроцедуры
