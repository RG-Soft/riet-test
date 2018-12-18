
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отчет.Периодичность = Перечисления.Периодичность.Месяц;
	Отчет.ДатаОтчета	= ТекущаяДата();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СформироватьОтчетНаСервере();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета)
	
	ТаблицаПериодов = Новый ТаблицаЗначений;
	ТаблицаПериодов.Колонки.Добавить("Интервал", ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.Дата));
	
	НачалоПериода = НачалоМесяца(ДатаОтчета);
	КонецПериода  = НачалоПериода;
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Стр = ТаблицаПериодов.Добавить();
		Стр.Интервал = НачалоПериода;
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		НачалоПериода = НачалоКвартала(НачалоПериода);
		Для Счет = 1 по 3 Цикл
			
			Стр = ТаблицаПериодов.Добавить();
			Стр.Интервал = НачалоПериода;
			
			НачалоПериода = ДобавитьМесяц(НачалоПериода, 1);
			
		КонецЦикла;
	ИначеЕсли Периодичность = Перечисления.Периодичность.Год Тогда
		НачалоПериода = НачалоГода(НачалоПериода);
		Для Счет = 1 по 12 Цикл
			
			Стр = ТаблицаПериодов.Добавить();
			Стр.Интервал = НачалоПериода;
			
			НачалоПериода = ДобавитьМесяц(НачалоПериода, 1);
			
		КонецЦикла;
	КонецЕсли;
	
	Возврат ТаблицаПериодов;
	
КонецФункции

&НаКлиенте
Процедура СформироватьОтчет(Команда)
	
	СформироватьОтчетНаСервере(); 

КонецПроцедуры

&НаСервере
Процедура СформироватьОтчетНаСервере()
	
	Если Не ЗначениеЗаполнено(Отчет.ДатаОтчета) Тогда
		Отчет.ДатаОтчета = ТекущаяДата();
	КонецЕсли;
	
	ОбъектОтчет = РеквизитФормыВЗначение("Отчет"); 
	РезультатТаб1.Очистить();
	ВывестиСхему(ОбъектОтчет, "BILLINGSPECIALISTBENCHMARK_1", РезультатТаб1);
	
	// отчет по Leg7
	Результат.Очистить(); 	
	ВывестиСхему(ОбъектОтчет, "LEG7BENCHMARK", Результат); 
	
	// отчет по Benchmark2
	РезультатТаб2.Очистить();
	ВывестиСхему(ОбъектОтчет, "BILLINGSPECIALISTBENCHMARK_2", РезультатТаб2); 

		
	////////
	// Чтобы не писалось "Отчет не сформирован…" 
	Элементы.РезультатТаб1.ОтображениеСостояния.Видимость = Ложь; 
	Элементы.РезультатТаб1.ОтображениеСостояния.ДополнительныйРежимОтображения = ДополнительныйРежимОтображения.НеИспользовать;

	Элементы.Результат.ОтображениеСостояния.Видимость = Ложь; 
	Элементы.Результат.ОтображениеСостояния.ДополнительныйРежимОтображения = ДополнительныйРежимОтображения.НеИспользовать;
	
	Элементы.РезультатТаб2.ОтображениеСостояния.Видимость = Ложь; 
	Элементы.РезультатТаб2.ОтображениеСостояния.ДополнительныйРежимОтображения = ДополнительныйРежимОтображения.НеИспользовать;

	
КонецПроцедуры

&НаКлиенте
Процедура ПериодичностьПриИзменении(Элемент)
	СформироватьОтчетНаСервере();
КонецПроцедуры

&НаСервере
Процедура ВывестиСхему(ОбъектОтчет, ИмяМакета, ТабличныйДокумент)
	
	ВнешниеДанные = Новый Структура;
	Если ИмяМакета = "BILLINGSPECIALISTBENCHMARK_1" Тогда
		ВнешниеДанные.Вставить("Данные", ДанныеБенчмарк1(Отчет.Периодичность, Отчет.ДатаОтчета));
	ИначеЕсли ИмяМакета = "BILLINGSPECIALISTBENCHMARK_2" Тогда 
		
	Иначе
		ВнешниеДанные.Вставить("Данные", ДанныеLeg7(Отчет.Периодичность, Отчет.ДатаОтчета));	
	КонецЕсли;
	
	ОСКД = ОбъектОтчет.ПолучитьМакет(ИмяМакета); 
	ТекстЗапроса = Неопределено;
	Попытка 
		ТексЗапроса = ОСКД.НаборыДанных[0].Запрос;
	Исключение
	КонецПопытки;
	//
	НастройкиОСКД = ОСКД.НастройкиПоУмолчанию; 
	//
	НастрйокаКолонки = Неопределено;
	Попытка
		НастройкаКолонки = НастройкиОСКД.Структура[0].Колонки[0].ПоляГруппировки.Элементы[0];
	Исключение
	КонецПопытки;
	
	Если Отчет.Периодичность = Перечисления.Периодичность.Месяц Тогда
		Если ТекстЗапроса <> Неопределено Тогда
			ТексЗапроса = СтрЗаменить(ТексЗапроса, "ГОД", "МЕСЯЦ");
		КонецЕсли;
		Если НЕ НастройкаКолонки = Неопределено Тогда
			НастройкаКолонки.НачалоПериода = НачалоМесяца(ТекущаяДата());
			НастройкаКолонки.КонецПериода  = КонецМесяца(ТекущаяДата());
		КонецЕсли;
	ИначеЕсли Отчет.Периодичность = Перечисления.Периодичность.Квартал Тогда
		Если ТекстЗапроса <> Неопределено Тогда
			ТексЗапроса = СтрЗаменить(ТексЗапроса, "ГОД", "КВАРТАЛ");
		КонецЕсли;
		Если НЕ НастройкаКолонки = Неопределено Тогда
			НастройкаКолонки.НачалоПериода = НачалоКвартала(ТекущаяДата());
			НастройкаКолонки.КонецПериода  = КонецКвартала(ТекущаяДата());
		КонецЕсли;
	Иначе
		Если НЕ НастройкаКолонки = Неопределено Тогда
			НастройкаКолонки.НачалоПериода = НачалоГода(ТекущаяДата());
			НастройкаКолонки.КонецПериода  = КонецГода(ТекущаяДата());
		КонецЕсли;
	КонецЕсли;
	
	Если ТекстЗапроса <> Неопределено Тогда
		ОСКД.НаборыДанных[0].Запрос = ТексЗапроса;	
	КонецЕсли;
	
	ТекущаяДата = НастройкиОСКД.ПараметрыДанных.Элементы.Найти("ТекущаяДата");
	Если ТекущаяДата <> Неопределено Тогда
		ТекущаяДата.Использование 	= Истина;
		ТекущаяДата.Значение 		= Отчет.ДатаОтчета;
	КонецЕсли;
	
	ПараметрыДанныхОСКД = НастройкиОСКД.ПараметрыДанных.Элементы; 
	
	ДанныеРасшифровкиКомпоновкиДанных = Новый ДанныеРасшифровкиКомпоновкиДанных;
	КомпоновщикМакетаОСКД = Новый КомпоновщикМакетаКомпоновкиДанных; 
	
	Макет = КомпоновщикМакетаОСКД.Выполнить(ОСКД, НастройкиОСКД,ДанныеРасшифровкиКомпоновкиДанных); 
	ПроцессорКомпоновкиОСКД = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновкиОСКД.Инициализировать(Макет, ВнешниеДанные,ДанныеРасшифровкиКомпоновкиДанных); 
	ПроцессорВыводаОСКД = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент; 
	ПроцессорВыводаОСКД.УстановитьДокумент(ТабличныйДокумент); 
	ПроцессорВыводаОСКД.Вывести(ПроцессорКомпоновкиОСКД);
	
	Если ИмяМакета = "BILLINGSPECIALISTBENCHMARK_1" Тогда
		ДанныеРасшифровкиТаб1 = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновкиДанных, УникальныйИдентификатор);
	ИначеЕсли ИмяМакета = "BILLINGSPECIALISTBENCHMARK_2" Тогда 
		ДанныеРасшифровкиТаб2 = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновкиДанных, УникальныйИдентификатор);
	Иначе
		ДанныеРасшифровки = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновкиДанных, УникальныйИдентификатор);
	КонецЕсли;
	
	ТабличныйДокумент.ПоказатьУровеньГруппировокСтрок(0);
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаОтчетаПриИзменении(Элемент)
	СформироватьОтчетНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеБенчмарк1(Периодичность, ДатаОтчета)
	
	ТаблицаПериодов = ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета);
	
	Запрос = Новый Запрос;

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Интервалы.Интервал
	|ПОМЕСТИТЬ ТаблицаИнтервалов
	|ИЗ
	|	&Интервалы КАК Интервалы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.Trip,
	|	Данные.Sum,
	|	Данные.Specialist,
	|	Данные.BillingSpecialist КАК BillingSpecialist,
	|	Данные.Title,
	|	Данные.Month,
	|	Данные.SortIndex
	|ПОМЕСТИТЬ ИсходнаяВыборка
	|ИЗ
	|	(ВЫБРАТЬ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripNonLawsonCompanies.Ссылка) КАК Trip,
	|		0 КАК Sum,
	|		TripNonLawsonCompanies.Specialist КАК Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist КАК BillingSpecialist,
	|		""Total trips verified by specialist"" КАК Title,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ) КАК Month,
	|		0 КАК SortIndex
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ
	|	
	|	ВЫБРАТЬ
	|		0,
	|		СУММА(TripNonLawsonCompanies.TotalCostsSumUSD / 1000),
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Total trips verified by specialist"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		0
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripNonLawsonCompanies.Ссылка),
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		2
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|		И НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ) = НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		0,
	|		СУММА(TripNonLawsonCompanies.TotalCostsSumUSD / 1000),
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		2
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|		И НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ) = НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripNonLawsonCompanies.Ссылка),
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (previous period)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		4
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist > TripNonLawsonCompanies.Closed
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		0,
	|		СУММА(TripNonLawsonCompanies.TotalCostsSumUSD / 1000),
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (previous period)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		4
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist > TripNonLawsonCompanies.Closed
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripNonLawsonCompanies.Ссылка),
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ),
	|		8
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist = ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		0,
	|		СУММА(TripNonLawsonCompanies.TotalCostsSumUSD / 1000),
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ),
	|		8
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist = ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripNonLawsonCompanies.Ссылка),
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (previous period)"",
	|		ТаблицаИнтервалов.Интервал,
	|		10
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|			ПО (ТаблицаИнтервалов.Интервал > НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ))
	|				И (TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД))
	|				И (НЕ TripNonLawsonCompanies.ПометкаУдаления)
	|				И (TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1))
	|				И (TripNonLawsonCompanies.Проведен)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		ТаблицаИнтервалов.Интервал
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		0,
	|		СУММА(TripNonLawsonCompanies.TotalCostsSumUSD / 1000),
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (previous period)"",
	|		ТаблицаИнтервалов.Интервал,
	|		10
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|			ПО (ТаблицаИнтервалов.Интервал > НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ))
	|				И (TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД))
	|				И (НЕ TripNonLawsonCompanies.ПометкаУдаления)
	|				И (TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1))
	|				И (TripNonLawsonCompanies.Проведен)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		ТаблицаИнтервалов.Интервал) КАК Данные
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Т.Trip,
	|	Т.Sum,
	|	ВЫБОР
	|		КОГДА НЕ Т.BillingSpecialist ЕСТЬ NULL  И НЕ Т.BillingSpecialist = Значение(Справочник.Пользователи.ПустаяСсылка)
	|				И НЕ Т.BillingSpecialist = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|			ТОГДА Т.BillingSpecialist
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА Т.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ КАК Specialist,
	|	Т.Title,
	|	Т.Month,
	|	Т.SortIndex
	|ИЗ
	|	(ВЫБРАТЬ
	|		ИсходнаяВыборка.Trip КАК Trip,
	|		ИсходнаяВыборка.Sum КАК Sum,
	|		ИсходнаяВыборка.Specialist КАК Specialist,
	|		ИсходнаяВыборка.BillingSpecialist КАК BillingSpecialist,
	|		ИсходнаяВыборка.Title КАК Title,
	|		ИсходнаяВыборка.Month КАК Month,
	|		ИсходнаяВыборка.SortIndex КАК SortIndex
	|	ИЗ
	|		ИсходнаяВыборка КАК ИсходнаяВыборка
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		СУММА(ИсходнаяВыборка.Trip),
	|		СУММА(0),
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist,
	|		""Total TRIP closed"",
	|		ИсходнаяВыборка.Month,
	|		6
	|	ИЗ
	|		ИсходнаяВыборка КАК ИсходнаяВыборка
	|	ГДЕ
	|		ИсходнаяВыборка.Title В (""Verified by specialist (current)"", ""Verified by specialist (current)"", ""Verified by specialist (previous period)"", ""Verified by specialist (previous period)"")
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist,
	|		ИсходнаяВыборка.Month
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		СУММА(0),
	|		СУММА(ИсходнаяВыборка.Sum),
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist,
	|		""Total TRIP closed"",
	|		ИсходнаяВыборка.Month,
	|		6
	|	ИЗ
	|		ИсходнаяВыборка КАК ИсходнаяВыборка
	|	ГДЕ
	|		ИсходнаяВыборка.Title В (""Verified by specialist (current)"", ""Verified by specialist (current)"", ""Verified by specialist (previous period)"", ""Verified by specialist (previous period)"")
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ИсходнаяВыборка.Month,
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		СУММА(ИсходнаяВыборка.Trip),
	|		СУММА(0),
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist,
	|		""Total TRIP pending"",
	|		ИсходнаяВыборка.Month,
	|		12
	|	ИЗ
	|		ИсходнаяВыборка КАК ИсходнаяВыборка
	|	ГДЕ
	|		ИсходнаяВыборка.Title В (""Not verified (current)"", ""Not verified (previous period)"")
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist,
	|		ИсходнаяВыборка.Month
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		СУММА(0),
	|		СУММА(ИсходнаяВыборка.Sum),
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist,
	|		""Total TRIP pending"",
	|		ИсходнаяВыборка.Month,
	|		12
	|	ИЗ
	|		ИсходнаяВыборка КАК ИсходнаяВыборка
	|	ГДЕ
	|		ИсходнаяВыборка.Title В (""Not verified (current)"", ""Not verified (previous period)"")
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ИсходнаяВыборка.Month,
	|		ИсходнаяВыборка.Specialist,
	|		ИсходнаяВыборка.BillingSpecialist) КАК Т
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.PlannersBillingSpecialistsMatching.СрезПоследних КАК PlannersBillingSpecialistsMatchingСрезПоследних
	|		ПО Т.Specialist = PlannersBillingSpecialistsMatchingСрезПоследних.Planner";
	
	Запрос.УстановитьПараметр("Интервалы", ТаблицаПериодов);
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "МЕСЯЦ");
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "КВАРТАЛ");
	КонецЕсли;
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
	
	Показатели = Новый Массив;
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total trips verified by specialist", 0));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Verified by specialist (current)", 2));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Verified by specialist (previous period)", 4));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total TRIP closed", 6));  	
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Not verified (current)", 8));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Not verified (previous period)", 10)); 
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total TRIP pending", 12));
	
	Для каждого ТекПоказатель из Показатели Цикл
		
		Если ТаблицаДанных.Найти(ТекПоказатель.Показатель, "Title") = Неопределено Тогда
			
			Стр = ТаблицаДанных.Добавить();
			Стр.Title 	  = ТекПоказатель.Показатель;
			Стр.sortIndex = ТекПоказатель.Индекс;
			Стр.Month 	  = НачалоМесяца(ТекущаяДата());	
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТаблицаДанных;
	
КонецФункции

&НаСервереБезКонтекста
Функция ДанныеLeg7(Периодичность, ДатаОтчета)
		
	ТаблицаПериодов = ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Интервалы.Интервал
	|ПОМЕСТИТЬ ТаблицаИнтервалов
	|ИЗ
	|	&Интервалы КАК Интервалы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Source.Trip,
	|	Source.Title,
	|	Source.Specialist,
	|	Source.Month,
	|	Source.SortIndex
	|ПОМЕСТИТЬ ИсходныеДанные
	|ИЗ
	|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripFinalDestinations.Ссылка) КАК Trip,
	|		""Sent to TMS (SH exist) period = ATA"" КАК Title,
	|		TripFinalDestinations.Ссылка.Specialist КАК Specialist,
	|		ТаблицаИнтервалов.Интервал КАК Month,
	|		0 КАК SortIndex
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|						И (TripDomesticOB.Ссылка.Проведен)
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) = ТаблицаИнтервалов.Интервал)
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (НЕ OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|				И (TripFinalDestinations.Ссылка.Проведен)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripFinalDestinations.Ссылка),
	|		""Sent to TMS from previous period"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		1
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|					И (TripDomesticOB.Ссылка.Проведен)
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) < ТаблицаИнтервалов.Интервал)
	|				И (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) >= НАЧАЛОПЕРИОДА(ТаблицаИнтервалов.Интервал, ГОД))
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (НЕ OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|				И (TripFinalDestinations.Ссылка.Проведен)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripFinalDestinations.Ссылка),
	|		""Not processed to TMS"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		3
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) = ТаблицаИнтервалов.Интервал)
	|				И (НЕ TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (НЕ OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripFinalDestinations.Ссылка),
	|		""No SH in TMS"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		4
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) = ТаблицаИнтервалов.Интервал)
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripFinalDestinations.Ссылка),
	|		""Pending from previous period"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		5
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|					И (TripDomesticOB.Ссылка.Проведен)
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) < ТаблицаИнтервалов.Интервал)
	|				И (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) >= НАЧАЛОПЕРИОДА(ТаблицаИнтервалов.Интервал, ГОД))
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|				И (TripFinalDestinations.Ссылка.Проведен)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал) КАК Source
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсходныеДанные.Trip,
	|	ИсходныеДанные.Title,
	|	ВЫБОР
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА ИсходныеДанные.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ КАК Specialist,
	|	ИсходныеДанные.Month,
	|	ИсходныеДанные.SortIndex
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.PlannersBillingSpecialistsMatching.СрезПоследних(&ТекущаяДата, ) КАК PlannersBillingSpecialistsMatchingСрезПоследних
	|		ПО ИсходныеДанные.Specialist = PlannersBillingSpecialistsMatchingСрезПоследних.Planner
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ИсходныеДанные.Trip,
	|	""Total proccessed"",
	|	ВЫБОР
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА ИсходныеДанные.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ КАК Specialist,
	|	ИсходныеДанные.Month,
	|	2
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.PlannersBillingSpecialistsMatching.СрезПоследних(&ТекущаяДата, ) КАК PlannersBillingSpecialistsMatchingСрезПоследних
	|		ПО ИсходныеДанные.Specialist = PlannersBillingSpecialistsMatchingСрезПоследних.Planner
	|ГДЕ
	|	ИсходныеДанные.Title В (""Sent to TMS (SH exist) period = ATA"", ""Sent to TMS from previous period"")
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ИсходныеДанные.Trip,
	|	""Total pending"",
	|	ВЫБОР
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА ИсходныеДанные.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ КАК Specialist,
	|	ИсходныеДанные.Month,
	|	6
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.PlannersBillingSpecialistsMatching.СрезПоследних(&ТекущаяДата, ) КАК PlannersBillingSpecialistsMatchingСрезПоследних
	|		ПО ИсходныеДанные.Specialist = PlannersBillingSpecialistsMatchingСрезПоследних.Planner
	|ГДЕ
	|	ИсходныеДанные.Title В (""Not processed to TMS"", ""No SH in TMS"", ""Pending from previous period"")";
	
	Запрос.УстановитьПараметр("Интервалы", ТаблицаПериодов);
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "МЕСЯЦ");
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "КВАРТАЛ");
	КонецЕсли;
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
	
	Показатели = Новый Массив;
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Sent to TMS (SH exist) period = ATA", 0));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Sent to TMS from previous period", 1));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total proccessed", 2)); 
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Not processed to TMS", 3));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "No SH in TMS", 4));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Pending from previous period", 5));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total pending", 6)); 
	
	Для каждого ТекПоказатель из Показатели Цикл
		
		Если ТаблицаДанных.Найти(ТекПоказатель.Показатель, "Title") = Неопределено Тогда
			
			Стр = ТаблицаДанных.Добавить();
			Стр.Title 	  = ТекПоказатель.Показатель;
			Стр.sortIndex = ТекПоказатель.Индекс;
			Стр.Month 	  = НачалоМесяца(ТекущаяДата());	
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТаблицаДанных;
	
КонецФункции

&НаКлиенте
Процедура РезультатТаб1ОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДеталиРасшифровки = Новый Структура;	
	ПолучитьРасшифровкуНаСервере(Расшифровка, ДеталиРасшифровки, 2);
	
	Если ДеталиРасшифровки.Количество() > 0
		И ДеталиРасшифровки.Свойство("Month") Тогда
		
		ДеталиРасшифровки.Вставить("ДатаОтчета", Отчет.ДатаОтчета);
		ДеталиРасшифровки.Вставить("Периодичность", Отчет.Периодичность);
		ДеталиРасшифровки.Вставить("ИмяСхемы", "BillingDashboardBenchmark1");
		
		// открываем детализирующий отчет
		ОткрытьФорму("Отчет.DashboardsDetalization.Форма.ФормаОтчета", Новый Структура("Отбор", ДеталиРасшифровки), ЭтаФорма, Истина);
		
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатТаб2ОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДеталиРасшифровки = Новый Структура;	
	ПолучитьРасшифровкуНаСервере(Расшифровка, ДеталиРасшифровки, 3);
	
	Если ДеталиРасшифровки.Количество() > 0 Тогда
		
		ДеталиРасшифровки.Вставить("ДатаОтчета", Отчет.ДатаОтчета);
		ДеталиРасшифровки.Вставить("Периодичность", Отчет.Периодичность);
		ДеталиРасшифровки.Вставить("ИмяСхемы", "BillingDashboardBenchmark2");
		
		// открываем детализирующий отчет
		ОткрытьФорму("Отчет.DashboardsDetalization.Форма.ФормаОтчета", Новый Структура("Отбор", ДеталиРасшифровки), ЭтаФорма, Истина);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДеталиРасшифровки = Новый Структура;	
	ПолучитьРасшифровкуНаСервере(Расшифровка, ДеталиРасшифровки, 1);
	
	Если ДеталиРасшифровки.Количество() > 0
		И ДеталиРасшифровки.Свойство("Month") Тогда
		
		ДеталиРасшифровки.Вставить("ДатаОтчета", Отчет.ДатаОтчета);
		ДеталиРасшифровки.Вставить("Периодичность", Отчет.Периодичность);
		ДеталиРасшифровки.Вставить("ИмяСхемы", "BillingDashboardLeg7");

		
		// открываем детализирующий отчет
		ОткрытьФорму("Отчет.DashboardsDetalization.Форма.ФормаОтчета", Новый Структура("Отбор", ДеталиРасшифровки), ЭтаФорма, Истина);
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРасшифровкуНаСервере(Расшифровка, ДеталиРасшифровки, ВариантРасшифровки) 
	
	Данные = Неопределено;
	
	Если ВариантРасшифровки = 1 Тогда
		Данные = ПолучитьИзВременногоХранилища(ДанныеРасшифровки);    
	ИначеЕсли ВариантРасшифровки = 2 Тогда
		Данные = ПолучитьИзВременногоХранилища(ДанныеРасшифровкиТаб1);    
	Иначе
		Данные = ПолучитьИзВременногоХранилища(ДанныеРасшифровкиТаб2);    
	КонецЕсли;
	
	ПолучитьЗначенияРасшифровки(Данные, ДеталиРасшифровки, Расшифровка);
	
КонецФункции 

&НаСервереБезКонтекста
Процедура ПолучитьЗначенияРасшифровки(Данные, ДеталиРасшифровки, Расшифровка)
	
	ЭлементРасшифровкиДанных = Данные.Элементы.Получить(Расшифровка);
	
	// выбираем поля. Если это группа, то обходим ее рекурсивно
	Если ТипЗнч(ЭлементРасшифровкиДанных) = Тип("ЭлементРасшифровкиКомпоновкиДанныхПоля") Тогда
		Поля = Данные.Элементы.Получить(Расшифровка).ПолучитьПоля(); 
	
		Для каждого ТекПоле из Поля Цикл
			ДеталиРасшифровки.Вставить(ТекПоле.Поле, ТекПоле.Значение);
		КонецЦикла;
	КонецЕсли;
	
	// далее просматриваем родителей
	Родители = ЭлементРасшифровкиДанных.ПолучитьРодителей(); 
	
	Для каждого Родитель из Родители Цикл
		
		ПолучитьЗначенияРасшифровки(Данные, ДеталиРасшифровки, Родитель.Идентификатор);
		
	КонецЦикла;
	
КонецПроцедуры