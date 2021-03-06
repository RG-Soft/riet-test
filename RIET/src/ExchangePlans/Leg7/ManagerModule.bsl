#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

// { RGS VShamin 27.07.2015 20:11:54 - S-I-0001168
//Функция ПолучитьСписокЗарегистрированныхПарселей(УзелОбмена) Экспорт
Функция ПолучитьСписокЗарегистрированныхПарселей(УзелОбмена, НастройкаОбмена) Экспорт
// } RGS VShamin 27.07.2015 20:11:58 - S-I-0001168
	
	МассивПарселей = Новый Массив;
	
	НачатьТранзакцию();
	
	Попытка
		
		// { RGS VShamin 27.07.2015 19:29:27 - S-I-0001168
		//ВыборкаИзменений = ПланыОбмена.ВыбратьИзменения(УзелОбмена, УзелОбмена.НомерОтправленного + 1);
		//Пока ВыборкаИзменений.Следующий() Цикл
		//	Данные = ВыборкаИзменений.Получить();
		//	Если ТипЗнч(Данные) = Тип("СправочникОбъект.Parcels") Тогда
		//		МассивПарселей.Добавить(Данные.Ссылка);
		//	КонецЕсли;
		//КонецЦикла;
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	ParcelsИзменения.Ссылка,
		               |	ЕСТЬNULL(Поставка.ATA, ДАТАВРЕМЯ(1, 1, 1)) КАК ShipmentATA,
		               |	ВЫБОР
		               |		КОГДА КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка ЕСТЬ NULL 
		               |			ТОГДА ИСТИНА
		               |		ИНАЧЕ ЛОЖЬ
		               |	КОНЕЦ КАК Local
		               |ИЗ
		               |	Справочник.Parcels.Изменения КАК ParcelsИзменения
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
		               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
		               |				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Поставка КАК Поставка
		               |				ПО ПоставкаУпаковочныеЛисты.Ссылка = Поставка.Ссылка
		               |			ПО КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка = ПоставкаУпаковочныеЛисты.УпаковочныйЛист
		               |				И (НЕ Поставка.Отменен)
		               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК КонсолидированныйПакетЗаявокНаПеревозку
		               |			ПО КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка = КонсолидированныйПакетЗаявокНаПеревозку.Ссылка
		               |		ПО (КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel = ParcelsИзменения.Ссылка)
		               |			И (НЕ КонсолидированныйПакетЗаявокНаПеревозку.Отменен)
		               |ГДЕ
		               |	ParcelsИзменения.Узел = &Узел";
		
		Запрос.УстановитьПараметр("Узел", УзелОбмена);
		
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			Если НастройкаОбмена.Leg6Report Тогда
			
				Если Выборка.ShipmentATA <> Дата("00010101")
					ИЛИ Выборка.Local Тогда
				
					МассивПарселей.Добавить(Выборка.Ссылка);
				
				КонецЕсли;
			
			Иначе
			
				МассивПарселей.Добавить(Выборка.Ссылка);
			
			КонецЕсли;
		
		КонецЦикла;
		// } RGS VShamin 27.07.2015 19:29:31 - S-I-0001168
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(
			"Failed to select changes of node '" + УзелОбмена.Наименование + "'",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.ПланыОбмена.Leg7,
			,
			ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат МассивПарселей;
	
КонецФункции

// { RGS VShamin 27.07.2015 14:16:32 - S-I-0001168
Функция ПолучитьСписокЗарегистрированныхТрипов(УзелОбмена) Экспорт
	
	МассивТрипов = Новый Массив;
	
	НачатьТранзакцию();
	
	Попытка
		ВыборкаИзменений = ПланыОбмена.ВыбратьИзменения(УзелОбмена, УзелОбмена.НомерОтправленного + 1);
		Пока ВыборкаИзменений.Следующий() Цикл
			Данные = ВыборкаИзменений.Получить();
			Если ТипЗнч(Данные) = Тип("ДокументОбъект.Trip") Тогда
				МассивТрипов.Добавить(Данные.Ссылка);
			КонецЕсли;
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(
			"Failed to select changes of node '" + УзелОбмена.Наименование + "'",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.ПланыОбмена.Leg7,
			,
			ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат МассивТрипов;
	
КонецФункции // } RGS VShamin 27.07.2015 14:16:35 - S-I-0001168

Функция ПолучитьСписокЗарегистрированныхПарселейБезУстановкиНомераСооббщения(УзелОбмена) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ParcelsИзменения.Ссылка
		|ИЗ
		|	Справочник.Parcels.Изменения КАК ParcelsИзменения
		|ГДЕ
		|	ParcelsИзменения.Узел = &Узел";

	Запрос.УстановитьПараметр("Узел", УзелОбмена);

	РезультатЗапроса = Запрос.Выполнить();

	Возврат РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

Функция ПарсельВСпискеЗарегистрированных(УзелОбмена, Парсель) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1 1
		|ИЗ
		|	Справочник.Parcels.Изменения КАК ParcelsИзменения
		|ГДЕ
		|	ParcelsИзменения.Узел = &Узел
		|	И ParcelsИзменения.Ссылка = &Парсель";

	Запрос.УстановитьПараметр("Узел", УзелОбмена);
	Запрос.УстановитьПараметр("Парсель", Парсель);

	РезультатЗапроса = Запрос.Выполнить();

	Возврат НЕ РезультатЗапроса.Пустой();
	
КонецФункции

Функция ПолучитьСоответствиеУзловОбменаИСервисПровайдеров(ТолькоСНастройкойВыгрузки = Истина) Экспорт

	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьСоответствиеУзловОбменаИСервисПровайдеров(ТолькоСНастройкойВыгрузки);

КонецФункции

Функция ПолучитьСоответствиеУзловОбменаИCCA() Экспорт

	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьСоответствиеУзловОбменаИCCA();

КонецФункции

Функция ПолучитьУзелОбменаПоСервисПровайдеру(СервисПровайдер) Экспорт
	
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьУзелОбменаПоСервисПровайдеру(СервисПровайдер);
	
КонецФункции

Функция СервисПровайдерУчаствуетВОбмене(СервисПровайдер) Экспорт
	
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.СервисПровайдерУчаствуетВОбмене(СервисПровайдер);
	
КонецФункции

Функция ПолучитьДатыНачалаВыгрузкиДокументовПоСкладам(УзелОбмена) Экспорт

	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьДатыНачалаВыгрузкиДокументовПоСкладам(УзелОбмена);

КонецФункции // ()

Функция ДокументНеБудетВыгружатьсяПоДатеНачалаВыгрузки(ДатаДокумента, Склад, СервисПровайдер) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЕСТЬNULL(МИНИМУМ(Leg7ДатыНачалаВыгрузкиДокументовПоСкладам.ДатаНачалаВыгрузкиДокументов), ДАТАВРЕМЯ(1,1,1)) КАК ДатаНачалаВыгрузкиДокументов
	|ИЗ
	|	ПланОбмена.Leg7.ДатыНачалаВыгрузкиДокументовПоСкладам КАК Leg7ДатыНачалаВыгрузкиДокументовПоСкладам
	|ГДЕ
	|	Leg7ДатыНачалаВыгрузкиДокументовПоСкладам.Ссылка.ServiceProvider = &ServiceProvider
	|	И Leg7ДатыНачалаВыгрузкиДокументовПоСкладам.Склад = &Склад";
	
	Запрос.УстановитьПараметр("ServiceProvider", СервисПровайдер);
	Запрос.УстановитьПараметр("Склад", Склад);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
	Возврат ДатаДокумента < Выборка.ДатаНачалаВыгрузкиДокументов;
	
КонецФункции

Процедура ЗарегистрироватьПарселиТрипаПриНеобходимости(УзелОбмена, Трип) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	1
		|ИЗ
		|	Справочник.Parcels.Изменения КАК ParcelsИзменения
		|ГДЕ
		|	ParcelsИзменения.Узел = &Узел
		|	И ParcelsИзменения.Ссылка В(&МассивПарселей)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	1
		|ИЗ
		|	Документ.Trip.Изменения КАК TripИзменения
		|ГДЕ
		|	TripИзменения.Узел = &Узел
		|	И TripИзменения.Ссылка = &Трип";
		
		
	МассивПарселей = Трип.Parcels.ВыгрузитьКолонку("Parcel");
	Запрос.УстановитьПараметр("МассивПарселей", МассивПарселей);
	Запрос.УстановитьПараметр("Узел", УзелОбмена);
	Запрос.УстановитьПараметр("Трип", Трип.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Трип.Ссылка) Тогда
		Для каждого ТекПарсель Из МассивПарселей Цикл
			ПланыОбмена.ЗарегистрироватьИзменения(УзелОбмена, ТекПарсель);
		КонецЦикла;
	Иначе
		ПланыОбмена.ЗарегистрироватьИзменения(УзелОбмена, Трип.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьНастройкуОбмена(УзелОбмена , ПроверятьГУИД = Ложь) Экспорт
	
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьНастройкуОбмена(УзелОбмена, ПроверятьГУИД);
	
КонецФункции

// { RGS VShamin 25.08.2015 13:09:44 - получение признака обмена Leg6
Функция ПолучитьИспользованиеLeg6ReportДляCCA(CCA) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьИспользованиеLeg6ReportДляCCA(CCA);
	
КонецФункции // } RGS VShamin 25.08.2015 13:09:44 - получение признака обмена Leg6

// { RGS LHristyc 29.06.2018 17:28:50 - S-I-0004942
Функция ПолучитьИспользованиеExportReportsДляCCA(CCA) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПолучитьИспользованиеExportReportsДляCCA(CCA);
	
КонецФункции // } RGS LHristyc 29.06.2018 17:29:06 - S-I-0004942

Функция РасширенныйСоставРедактируемыхПолейLeg6(CCA) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.РасширенныйСоставРедактируемыхПолейLeg6(CCA);
	
КонецФункции // } RGS VShamin 25.08.2015 13:09:44 - получение признака обмена Leg6

// { RGS VShamin 25.08.2015 13:09:44 - проверка Process level
Функция ПроверитьProcessLevelПоCCA(CCA, ProcessLevel) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Возврат LocalDistributionОбменДаннымиСерверПовтИспСеанс.ПроверитьProcessLevelПоCCA(CCA, ProcessLevel);
	
КонецФункции // } RGS VShamin 25.08.2015 13:09:44 - проверка Process level

#КонецЕсли