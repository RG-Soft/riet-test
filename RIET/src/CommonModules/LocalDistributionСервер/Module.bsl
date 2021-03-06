
////////////////////////////////////////////////////////////////////////////////////////////
// РЕГЛАМЕНТНЫЕ ЗАДАНИЯ

Процедура PushLeg7Reports() Экспорт
	
	Обработки.LocalDistributionDesktop.PushLeg7Reports(Истина);
	
КонецПроцедуры

Процедура PullReportsFromServiceProvidersEmails() Экспорт
	
	// Процедура для одноименного регламентного задания
	УстановитьПривилегированныйРежим(Истина);
	
	ИнтернетПочтовыйПрофиль = ImportExportСерверПовтИспСеанс.ПолучитьИнтернетПочтовыйПрофиль();
 	ИнтернетПочта = ImportExportСервер.ПодключитьсяКИнтернетПочте(ИнтернетПочтовыйПрофиль);
	
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	ИспользоватьСистемнуюУчетнуюЗапись = Истина;
	ИнтернетПочтовыйПрофильRCA = ImportExportСерверПовтИспСеанс.ПолучитьИнтернетПочтовыйПрофиль(ИспользоватьСистемнуюУчетнуюЗапись);
 	ИнтернетПочтаRCA = ImportExportСервер.ПодключитьсяКИнтернетПочте(ИнтернетПочтовыйПрофильRCA);
	
	ДанныеДляОтправкиОтвета = Новый Структура;
	ДанныеДляОтправкиОтвета.Вставить("ИнтернетПочта", ИнтернетПочта);
	ДанныеДляОтправкиОтвета.Вставить("ИнтернетПочтаRCA", ИнтернетПочтаRCA);
	ДанныеДляОтправкиОтвета.Вставить("АдресОтправителя", ИнтернетПочтовыйПрофиль.ПользовательSMTP); 
	//ДанныеДляОтправкиОтвета.Вставить("АдресПолучателя", "");
	//ДанныеДляОтправкиОтвета.Вставить("ТемаИсходногоПисьма", "");
	// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
	
	// Что бы дальше не произошло - нам нужно гарантированно отключиться
	// Поэтому перехватим описание ошибки, чтобы потом вызывать ее после отключения
	ОбработанныеПисьма = Новый Массив;
	ОписаниеОшибки = Неопределено;
	Попытка
		
		НовыеПисьма = ImportExportСервер.ПолучитьUnprocessedEmails(ИнтернетПочта, ИнтернетПочтовыйПрофиль.ПользовательIMAP);
		// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
		//ОбработанныеПисьма = Обработки.PullReportsFromServiceProvidersEmails.ОбработатьПисьма(НовыеПисьма, ИнтернетПочта, ИнтернетПочтовыйПрофиль.ПользовательSMTP);
		ОбработанныеПисьма = Обработки.PullReportsFromServiceProvidersEmails.ОбработатьПисьма(НовыеПисьма, ДанныеДляОтправкиОтвета);
		// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
				
	Исключение
		
		ОписаниеОшибки = "Failed to load Leg7 reports from e-mails:
			|" + ОписаниеОшибки();
			
	КонецПопытки;
	
	ИнтернетПочта.Отключиться();
	// { RGS VChaplygin 27.10.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	ИнтернетПочтаRCA.Отключиться();
	// } RGS VChaplygin 27.10.2016 8:42:40 - Добавим аварийный почтовый аккаунт
	
	// Зарегистрируем обработанные письма
	МассивИдентификаторов = Новый Массив;
	Для Каждого ОбработанноеПисьмо Из ОбработанныеПисьма Цикл
		МассивИдентификаторов.Добавить(ОбработанноеПисьмо.Идентификатор[0]);		
	КонецЦикла;

	Если МассивИдентификаторов.Количество() Тогда
		РегистрыСведений.UIDsOfProcessedEmails.ДобавитьНесколько(МассивИдентификаторов, ИнтернетПочтовыйПрофиль.ПользовательIMAP);
	КонецЕсли;
	
	Если ОписаниеОшибки <> Неопределено Тогда
		ВызватьИсключение ОписаниеОшибки;	
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьDaysETAWithoutATAВTrips() Экспорт
	
	// закрашиваем строки Trips, на основании самой ранней ETA, у которой не заполнена ATA, используя следующую разбивку:
	// Current date > ETA+14 days – red
	// Current date > ETA+7 days  – orange
	// Current date > ETA+2 days  – yellow
	  	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МИНИМУМ(TripFinalDestinations.ETA) КАК ETA,
		|	TripFinalDestinations.Ссылка КАК Trip
		|ИЗ
		|	Документ.Trip.FinalDestinations КАК TripFinalDestinations
		|ГДЕ
		|	TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
		|
		|СГРУППИРОВАТЬ ПО
		|	TripFinalDestinations.Ссылка";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		DaysETAWithoutATA = (НачалоДня(ТекущаяДата()) - НачалоДня(Выборка.ETA)) / 86400;
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		TripОбъект = Выборка.Trip.ПолучитьОбъект();
		TripОбъект.DaysETAWithoutATA = DaysETAWithoutATA;
		TripОбъект.ОбменДанными.Загрузка = Истина;
		TripОбъект.Записать();
		ЗафиксироватьТранзакцию();
		
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ 
		|	TripFinalDestinations.Ссылка КАК Trip,
		|	МИНИМУМ(TripFinalDestinations.ATA) КАК ATA
		|ИЗ
		|	Документ.Trip.FinalDestinations КАК TripFinalDestinations
		|ГДЕ
		|	TripFinalDestinations.ATA <> ДАТАВРЕМЯ(1, 1, 1)
		|	И TripFinalDestinations.Ссылка.DaysETAWithoutATA <> 0
		|
		|СГРУППИРОВАТЬ ПО
		|	TripFinalDestinations.Ссылка";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		TripОбъект = Выборка.Trip.ПолучитьОбъект();
		TripОбъект.DaysETAWithoutATA = 0;
		TripОбъект.ОбменДанными.Загрузка = Истина;
		TripОбъект.Записать();
		ЗафиксироватьТранзакцию();
		
	КонецЦикла;
	
КонецПроцедуры

Процедура PullWONoFromTMS() Экспорт
	
	Обработки.PullWONoFromTMS.PullDataFromTMS();
	
КонецПроцедуры

Процедура КонтрольЗагрузкиLeg7Reports() Экспорт 
	
	//проверка для каждой записи регистра Leg7ReceivedReportsDate,
	//если день даты последней загрузки меньше текущего дня 
	//(т.е. последний отчет был загружен вчера или еще раньше), 
	//тогда отправляется уведомление на riet-support 

	ТекстСообщения = "";
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекДата", ТекущаяДатаСеанса());
	Запрос.Текст = "ВЫБРАТЬ
	               |	Leg7ReceivedReportsDate.ReportsDate,
	               |	ServiceProviders.Ссылка КАК ServiceProvider
	               |ИЗ
	               |	Справочник.ServiceProviders КАК ServiceProviders
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Leg7ReceivedReportsDate КАК Leg7ReceivedReportsDate
	               |		ПО ServiceProviders.EMailBox = Leg7ReceivedReportsDate.Sender
	               |ГДЕ
	               |	НЕ ServiceProviders.ПометкаУдаления
	               |	И ДЕНЬ(Leg7ReceivedReportsDate.ReportsDate) <> ДЕНЬ(&ТекДата)";
	
	ВыборкаLeg7ReceivedReportsDate = Запрос.Выполнить().Выбрать();
	Пока ВыборкаLeg7ReceivedReportsDate.Следующий() Цикл
		
		ПрошлоСПоследнейЗагрузкиВЧасах = (ТекущаяДатаСеанса() - ВыборкаLeg7ReceivedReportsDate.ReportsDate) / 3600;
		Если ПрошлоСПоследнейЗагрузкиВЧасах > 24 Тогда 
			ПрошлоСПоследнейЗагрузкиВДнях = Окр(ПрошлоСПоследнейЗагрузкиВЧасах/24, 0, РежимОкругления.Окр15как10);
			TimePassed = СокрЛП(ПрошлоСПоследнейЗагрузкиВДнях) + ?(ПрошлоСПоследнейЗагрузкиВДнях = 1, " day.", " days.");
		иначе
			TimePassed = СокрЛП(Окр(ПрошлоСПоследнейЗагрузкиВЧасах, 0, РежимОкругления.Окр15как10)) + " hours.";
		КонецЕсли;
		
		Если Не ПустаяСтрока(ТекстСообщения) Тогда
			ТекстСообщения = ТекстСообщения + Символы.ПС;
		КонецЕсли;
		
		ТекстСообщения = ТекстСообщения + 
			"For service provider '" + СокрЛП(ВыборкаLeg7ReceivedReportsDate.ServiceProvider) + "' the date-time of the last loaded Leg7 reports is '" + ВыборкаLeg7ReceivedReportsDate.ReportsDate + "'.
			|Since the last successfull loading has passed " + TimePassed;
		
	КонецЦикла;

	Если Не ПустаяСтрока(ТекстСообщения) Тогда 
			
		РГСофт.ЗарегистрироватьПочтовоеСообщение(
		// { RGS AGorlenko 26.10.2014 19:42:13 - для универсальности адресатов задаем в константе
		//	"riet-support-ld@slb.com",
			Константы.АдресатыПолученияОтчетаControlOverLeg7ReportsLoading.Получить(),
		// } RGS AGorlenko 26.10.2014 19:42:39 - для универсальности адресатов задаем в константе
			"Control over Leg7 reports loading",
			ТекстСообщения);  
			
	КонецЕсли;
	
КонецПроцедуры
 
////////////////////////////////////////////////////////////////////////////////////////////

Функция ОбновитьTripDomesticOB(Объект) Экспорт 
	
	МассивParcels = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.Parcels, "Parcel");
	
	ТЗданныхItems = ПолучитьДанныеItemsToTMS(МассивParcels, Объект.Final);
	    		
	ТЗOB = ТЗданныхItems.Скопировать(Новый Структура("TMS", Истина), "WarehouseTo,LegalEntity,Gold,AU,Activity");
	ТЗOB.Свернуть("WarehouseTo,LegalEntity,Gold,AU,Activity");
	
	ТЗTripOB = Объект.DomesticOB.Выгрузить();
	
	СтруктураПоиска = Новый Структура("WarehouseTo,LegalEntity,Gold,AU,Activity");
	
	// добавим новые строки OB
	Для Каждого СтрокаТЗOB из ТЗOB Цикл 
		
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаТЗOB);
		
		//Urgency
		Urgency = Перечисления.Urgencies.Standard;
		
		МассивСтрокДляUrgency = ТЗданныхItems.НайтиСтроки(СтруктураПоиска);
		Для Каждого ЭлементМассива из МассивСтрокДляUrgency Цикл
			
			Если ЭлементМассива.Urgency = Перечисления.Urgencies.Emergency Тогда 
				
				Urgency = Перечисления.Urgencies.Emergency;
				
			ИначеЕсли ЭлементМассива.Urgency = Перечисления.Urgencies.Urgent
				И Urgency <> Перечисления.Urgencies.Emergency Тогда 
				
				Urgency = Перечисления.Urgencies.Urgent;
				
			КонецЕсли;
			
		КонецЦикла;
		
		МассивСтрокТЗ = ТЗTripOB.НайтиСтроки(СтруктураПоиска);
		
		Если МассивСтрокТЗ.Количество() = 0 Тогда 
			НоваяСтрокаOB = Объект.DomesticOB.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрокаOB, СтрокаТЗOB);
			НоваяСтрокаOB.Urgency = Urgency;
			ChangeSentToTMS = Истина;
			Продолжить;
		КонецЕсли;		
		
		ТЗTripOB.Удалить(МассивСтрокТЗ[0]);
		
	КонецЦикла;
	
	// удалим старые строки OB
	Для Каждого СтрокаТЗ из ТЗTripOB Цикл 
		
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаТЗ);
		МассивСтрок = Объект.DomesticOB.НайтиСтроки(СтруктураПоиска);
		
		Объект.DomesticOB.Удалить(МассивСтрок[0]);
		        				
	КонецЦикла;
	
	// обновим номера OB:OBG(X)yymmS(префикс)-TTTtt
	Сч = 1;
	Для Каждого СтрокаOB из Объект.DomesticOB Цикл 
		СтрокаOB.OBNo = "OB" + ?(СтрокаOB.Gold, "G", "X") + Объект.Номер + ?(Сч < 10, "0", "") + СокрЛП(Сч);
		Сч = Сч + 1;
	КонецЦикла;
	
КонецФункции

Функция ПолучитьДанныеItemsToTMS(МассивParcels, Final) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивParcels", МассивParcels);
	Запрос.УстановитьПараметр("Final", Final);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ParcelsДетали.Ссылка.WarehouseTo КАК WarehouseTo,
	               |	ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ) КАК Gold,
	               |	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК AU,
	               |	ParcelsДетали.СтрокаИнвойса.Активити КАК Activity,
	               |	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК КостЦентр,
	               |	ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.КостЦентр.DefaultActivity, """") КАК DefaultActivity,
	               |	ParcelsДетали.СтрокаИнвойса.Активити КАК Активити,
	               |	ParcelsДетали.Qty КАК Количество,
	               |	ParcelsДетали.СтрокаИнвойса.Классификатор КАК Классификатор,
	               |	ParcelsДетали.СтрокаИнвойса.НаименованиеТовара КАК НаименованиеТовара,
	               |	ParcelsДетали.СтрокаИнвойса.КодПоИнвойсу КАК КодПоИнвойсу,
	               |	ParcelsДетали.СтрокаИнвойса КАК Ссылка,
	               |	ParcelsДетали.СтрокаИнвойса.Инвойс КАК Invoice,
	               |	ParcelsДетали.СтрокаИнвойса.LocalOnly КАК Local,
	               |	ParcelsДетали.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку КАК СтрокаЗаявкиНаЗакупку,
	               |	ParcelsДетали.СтрокаИнвойса.НомерЗаявкиНаЗакупку КАК НомерЗаявкиНаЗакупку,
	               |	ParcelsДетали.Ссылка.Urgency КАК Urgency,
	               |	ParcelsДетали.СтрокаИнвойса.SoldTo КАК SoldTo,
	               |	ВЫБОР
	               |		КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <= &Final
	               |				И ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка)
	               |				И ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <> ДАТАВРЕМЯ(1, 1, 1)
	               |			ТОГДА ИСТИНА
	               |		ИНАЧЕ ЛОЖЬ
	               |	КОНЕЦ КАК TMS
	               |ПОМЕСТИТЬ ВТ_ParcelsДетали
	               |ИЗ
	               |	Справочник.Parcels.Детали КАК ParcelsДетали
	               |ГДЕ
	               |	ParcelsДетали.Ссылка В(&МассивParcels)
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	AU,
	               |	SoldTo
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_ParcelsДетали.WarehouseTo,
	               |	ВЫБОР
	               |		КОГДА ВТ_ParcelsДетали.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	               |			ТОГДА ВТ_ParcelsДетали.SoldTo.LegalEntityForLeg7
	               |		ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
	               |	КОНЕЦ КАК LegalEntity,
	               |	ВТ_ParcelsДетали.Gold,
	               |	ВТ_ParcelsДетали.AU,
	               |	ВТ_ParcelsДетали.Activity,
	               |	ВТ_ParcelsДетали.КостЦентр,
	               |	ВТ_ParcelsДетали.DefaultActivity,
	               |	ВТ_ParcelsДетали.Активити,
	               |	ВТ_ParcelsДетали.Количество,
	               |	ВТ_ParcelsДетали.Классификатор,
	               |	ВТ_ParcelsДетали.НаименованиеТовара,
	               |	ВТ_ParcelsДетали.КодПоИнвойсу,
	               |	ВТ_ParcelsДетали.Ссылка,
	               |	ВТ_ParcelsДетали.Invoice,
	               |	ВТ_ParcelsДетали.Local,
	               |	ВТ_ParcelsДетали.СтрокаЗаявкиНаЗакупку,
	               |	ВТ_ParcelsДетали.НомерЗаявкиНаЗакупку,
	               |	ВТ_ParcelsДетали.Urgency,
	               |	ВТ_ParcelsДетали.TMS
	               |ИЗ
	               |	ВТ_ParcelsДетали КАК ВТ_ParcelsДетали
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities.СрезПоследних(
	               |				&Final,
	               |				(AU, ParentCompany) В
	               |					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |						ВТ_ParcelsДетали.AU,
	               |						ВТ_ParcelsДетали.SoldTo
	               |					ИЗ
	               |						ВТ_ParcelsДетали КАК ВТ_ParcelsДетали)) КАК AUsAndLegalEntitiesСрезПоследних
	               |		ПО ВТ_ParcelsДетали.SoldTo = AUsAndLegalEntitiesСрезПоследних.ParentCompany
	               |			И ВТ_ParcelsДетали.AU = AUsAndLegalEntitiesСрезПоследних.AU";
	
	Возврат Запрос.Выполнить().Выгрузить();
		
КонецФункции

Функция ПолучитьСписокLeg7WarehouseFrom() Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ServiceProvidersWarehouses.Warehouse
		|ИЗ
		|	Справочник.ServiceProviders.Warehouses КАК ServiceProvidersWarehouses
		|ГДЕ
		|	НЕ ServiceProvidersWarehouses.Ссылка.ПометкаУдаления
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Warehouses.Ссылка
		|ИЗ
		|	Справочник.Warehouses КАК Warehouses
		|ГДЕ
		|	НЕ Warehouses.ПометкаУдаления
		|	И Warehouses.Port";
		
	Результат = Запрос.Выполнить().Выгрузить();
	
	СписокWarehouses = Новый СписокЗначений();
	СписокWarehouses.ЗагрузитьЗначения(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Результат, "Warehouse"));
	
	Возврат СписокWarehouses;
	
КонецФункции

Процедура АктуализироватьОчередьTripDomesticOB(Объект) Экспорт
	
	Если НЕ Объект.ДополнительныеСвойства.Свойство("ТаблицаСтарыxДанныхDomesticOB") Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаСтарыxДанныхDomesticOB = Объект.ДополнительныеСвойства.ТаблицаСтарыxДанныхDomesticOB;
	
	СтруктураОтбора = Новый Структура("OBNo");
	
	МассивУдаленных = Новый Массив;
	Для каждого СтрокаТЗ Из ТаблицаСтарыxДанныхDomesticOB Цикл
		СтруктураОтбора.OBNo = СтрокаТЗ.OBNo;
		НайденныеСтроки = Объект.DomesticOB.НайтиСтроки(СтруктураОтбора);
		Если НайденныеСтроки.Количество() = 0 Тогда
			МассивУдаленных.Добавить(СтрокаТЗ.OBNo);
		КонецЕсли;
	КонецЦикла;
	
	ТаблицаДобавленных = Новый ТаблицаЗначений;
	ТаблицаДобавленных.Колонки.Добавить("OBNo", Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(15)));
	Для каждого СтрокаТЧ Из Объект.DomesticOB Цикл
		СтруктураОтбора.OBNo = СтрокаТЧ.OBNo;
		НайденныеСтроки = ТаблицаСтарыxДанныхDomesticOB.НайтиСтроки(СтруктураОтбора);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрока = ТаблицаДобавленных.Добавить();
			НоваяСтрока.OBNo = СтрокаТЧ.OBNo;
		КонецЕсли;
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// удалим из очереди удаленные
	Если МассивУдаленных.Количество() > 0 Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	OBNoQueue.OBNo
		|ИЗ
		|	РегистрСведений.OBNoQueue КАК OBNoQueue
		|ГДЕ
		|	OBNoQueue.OBNo В(&МассивУдаленных)";
		Запрос.УстановитьПараметр("МассивУдаленных", МассивУдаленных);
		Результат = Запрос.Выполнить();
		
		Если НЕ Результат.Пустой() Тогда
			НЗ = РегистрыСведений.OBNoQueue.СоздатьНаборЗаписей();
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				НЗ.Очистить();
				НЗ.Отбор.OBNo.Установить(Выборка.OBNo);
				НЗ.Записать(Истина);
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
	// добавим в очередь новые
	Если ТаблицаДобавленных.Количество() > 0 Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ТаблицаДобавленных.OBNo КАК OBNo
		|ПОМЕСТИТЬ ВТ_ТаблицаДобавленных
		|ИЗ
		|	&ТаблицаДобавленных КАК ТаблицаДобавленных
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	OBNo
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВложенныйЗапрос.OBNo,
		|	СУММА(ВложенныйЗапрос.Найден) КАК Найден
		|ИЗ
		|	(ВЫБРАТЬ
		|		ВТ_ТаблицаДобавленных.OBNo КАК OBNo,
		|		ВЫБОР
		|			КОГДА OBNoQueue.OBNo ЕСТЬ NULL 
		|				ТОГДА 0
		|			ИНАЧЕ 1
		|		КОНЕЦ КАК Найден
		|	ИЗ
		|		ВТ_ТаблицаДобавленных КАК ВТ_ТаблицаДобавленных
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoQueue КАК OBNoQueue
		|			ПО ВТ_ТаблицаДобавленных.OBNo = OBNoQueue.OBNo
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		ВТ_ТаблицаДобавленных.OBNo,
		|		ВЫБОР
		|			КОГДА OBNoAndWONo.OBNo ЕСТЬ NULL 
		|				ТОГДА 0
		|			ИНАЧЕ 1
		|		КОНЕЦ
		|	ИЗ
		|		ВТ_ТаблицаДобавленных КАК ВТ_ТаблицаДобавленных
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
		|			ПО ВТ_ТаблицаДобавленных.OBNo = OBNoAndWONo.OBNo) КАК ВложенныйЗапрос
		|
		|СГРУППИРОВАТЬ ПО
		|	ВложенныйЗапрос.OBNo
		|
		|ИМЕЮЩИЕ
		|	СУММА(ВложенныйЗапрос.Найден) = 0";
		
		Запрос.УстановитьПараметр("ТаблицаДобавленных", ТаблицаДобавленных);
		Результат = Запрос.Выполнить();
		
		Если Не Результат.Пустой() Тогда
			НЗ = РегистрыСведений.OBNoQueue.СоздатьНаборЗаписей();
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				НЗ.Очистить();
				НЗ.Отбор.OBNo.Установить(Выборка.OBNo);
				Запись = НЗ.Добавить();
				Запись.OBNo = Выборка.OBNo;
				НЗ.Записать(Истина);
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьДанныеWarehouseToLegalEntity(МассивParcels, Дата) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивParcels", МассивParcels);
	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	ParcelsДетали.Ссылка.WarehouseTo,
	               |	ParcelsДетали.СтрокаИнвойса.SoldTo КАК SoldTo,
	               |	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК КостЦентр
	               |ПОМЕСТИТЬ ВТ_ParcelsДетали
	               |ИЗ
	               |	Справочник.Parcels.Детали КАК ParcelsДетали
	               |ГДЕ
	               |	ParcelsДетали.Ссылка В(&МассивParcels)
	               |	И ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка)
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	SoldTo,
	               |	КостЦентр
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	ВТ_ParcelsДетали.WarehouseTo,
	               |	ВЫБОР
	               |		КОГДА ВТ_ParcelsДетали.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	               |			ТОГДА ВТ_ParcelsДетали.SoldTo.LegalEntityForLeg7
	               |		ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
	               |	КОНЕЦ КАК LegalEntity
	               |ИЗ
	               |	ВТ_ParcelsДетали КАК ВТ_ParcelsДетали
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities.СрезПоследних(
	               |				&Период,
	               |				(ParentCompany, AU) В
	               |					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |						ВТ_ParcelsДетали.SoldTo,
	               |						ВТ_ParcelsДетали.КостЦентр
	               |					ИЗ
	               |						ВТ_ParcelsДетали КАК ВТ_ParcelsДетали)) КАК AUsAndLegalEntitiesСрезПоследних
	               |		ПО ВТ_ParcelsДетали.SoldTo = AUsAndLegalEntitiesСрезПоследних.ParentCompany
	               |			И ВТ_ParcelsДетали.КостЦентр = AUsAndLegalEntitiesСрезПоследних.AU";
	
	Возврат Запрос.Выполнить().Выгрузить();
		
КонецФункции

Функция ПолучитьРасширенныеДанныеFinalDestination(МассивParcels, Дата) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивParcels", МассивParcels);
	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.Текст = 
	               "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	ParcelsДетали.СтрокаИнвойса КАК Item,
	               |	ParcelsДетали.СтрокаИнвойса.Наименование КАК ItemNo,
	               |	ParcelsДетали.Ссылка.WarehouseTo КАК WarehouseTo,
	               |	ParcelsДетали.СтрокаИнвойса.SoldTo КАК SoldTo,
	               |	ВЫБОР
	               |		КОГДА НЕ ЗаявкиНаЗакупку.БОРГ ЕСТЬ NULL И ЗаявкиНаЗакупку.БОРГ <> ЗНАЧЕНИЕ(Справочник.BORGs.ПустаяСсылка)
	               |			ТОГДА ЗаявкиНаЗакупку.БОРГ
	               |		КОГДА НЕ BORGsOfNonPOItems.BORG ЕСТЬ NULL 
	               |			ТОГДА BORGsOfNonPOItems.BORG
	               |		КОГДА НЕ BORGs.Ссылка ЕСТЬ NULL 
	               |			ТОГДА BORGs.Ссылка
	               |		ИНАЧЕ ЕСТЬNULL(BORGs1.Ссылка, ЗНАЧЕНИЕ(Справочник.BORGs.ПустаяСсылка))
	               |	КОНЕЦ КАК Borg,
	               |	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК КостЦентр,
	               |	ParcelsДетали.СтрокаИнвойса.LocalOnly КАК LocalOnly
	               |ПОМЕСТИТЬ ВТ_ParcelsДетали
	               |ИЗ
	               |	Справочник.Parcels.Детали КАК ParcelsДетали
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.BORGs КАК BORGs
	               |		ПО (ПОДСТРОКА(ParcelsДетали.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 4) = BORGs.Код)
	               |			И (НЕ BORGs.ПометкаУдаления)
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.BORGs КАК BORGs1
	               |		ПО (ПОДСТРОКА(ParcelsДетали.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) = BORGs1.Код)
	               |			И (НЕ BORGs1.ПометкаУдаления)
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ЗаявкиНаЗакупку КАК ЗаявкиНаЗакупку
	               |		ПО ParcelsДетали.СтрокаИнвойса.НомерЗаявкиНаЗакупку = ЗаявкиНаЗакупку.Код
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.BORGsOfNonPOItems КАК BORGsOfNonPOItems
	               |		ПО ParcelsДетали.СтрокаИнвойса = BORGsOfNonPOItems.Item
	               |ГДЕ
	               |	ParcelsДетали.Ссылка В(&МассивParcels)
	               |	И ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка)
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	SoldTo,
	               |	КостЦентр
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	ВТ_ParcelsДетали.Item,
	               |	ВТ_ParcelsДетали.ItemNo,
	               |	ВТ_ParcelsДетали.WarehouseTo,
	               |	ВТ_ParcelsДетали.SoldTo,
	               |	ВТ_ParcelsДетали.Borg,
	               |	ВЫБОР
	               |		КОГДА ВТ_ParcelsДетали.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	               |			ТОГДА ВТ_ParcelsДетали.SoldTo.LegalEntityForLeg7
	               |		ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
	               |	КОНЕЦ КАК LegalEntity,
	               |	ВТ_ParcelsДетали.LocalOnly
	               |ИЗ
	               |	ВТ_ParcelsДетали КАК ВТ_ParcelsДетали
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities.СрезПоследних(
	               |				&Период,
	               |				(ParentCompany, AU) В
	               |					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |						ВТ_ParcelsДетали.SoldTo,
	               |						ВТ_ParcelsДетали.КостЦентр
	               |					ИЗ
	               |						ВТ_ParcelsДетали КАК ВТ_ParcelsДетали)) КАК AUsAndLegalEntitiesСрезПоследних
	               |		ПО ВТ_ParcelsДетали.SoldTo = AUsAndLegalEntitiesСрезПоследних.ParentCompany
	               |			И ВТ_ParcelsДетали.КостЦентр = AUsAndLegalEntitiesСрезПоследних.AU";
	
	Возврат Запрос.Выполнить().Выгрузить();
		
КонецФункции

Функция ОбновитьTripFinalDestinations(TripFinalDestinations, МассивParcels, Дата) Экспорт
	
	Модифицированность = Ложь;
	
	ТаблицаWarehouseToLegalEntity = LocalDistributionСервер.ПолучитьДанныеWarehouseToLegalEntity(МассивParcels, Дата);
	СтруктураПоиска = Новый Структура("WarehouseTo, LegalEntity");
	
	// на всякий случай свернем строки, чтобы точно не было дублей
	КоличествоСтрокДоСвертки = TripFinalDestinations.Количество();
	TripFinalDestinations.Свернуть("WarehouseTo, LegalEntity, Waybill, ETA, ATA", "Mileage");
	КоличествоСтрокПослеСвертки = TripFinalDestinations.Количество();
	Если КоличествоСтрокДоСвертки <> КоличествоСтрокПослеСвертки Тогда
		Модифицированность = Истина;
	КонецЕсли;
	
	// Удалим старые строки
	ы = 0;
	Пока ы < TripFinalDestinations.Количество() Цикл
		
		СтрокаТЧ = TripFinalDestinations[ы];
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.WarehouseTo) Тогда
			TripFinalDestinations.Удалить(СтрокаТЧ);
			Модифицированность = Истина;
		Иначе
			
			ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаТЧ);
			Если ТаблицаWarehouseToLegalEntity.НайтиСтроки(СтруктураПоиска).Количество() = 0 Тогда
				TripFinalDestinations.Удалить(СтрокаТЧ);
				Модифицированность = Истина;
			Иначе
				ы = ы + 1;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
		
	// Добавим новые строки
	//СтруктураПоиска = Новый Структура("WarehouseTo");
	Для Каждого ТекСтрока Из ТаблицаWarehouseToLegalEntity Цикл
		
		//СтруктураПоиска.WarehouseTo = WarehouseTo;
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, ТекСтрока);
		НайденныеСтроки = TripFinalDestinations.НайтиСтроки(СтруктураПоиска);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрока = TripFinalDestinations.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ТекСтрока);
			Модифицированность = Истина;
		КонецЕсли;
		
	КонецЦикла;
	   		
	Возврат Модифицированность;
	
КонецФункции
