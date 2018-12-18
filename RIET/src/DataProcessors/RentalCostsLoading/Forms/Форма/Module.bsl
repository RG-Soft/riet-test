
&НаКлиенте
Процедура ЗагрузитьДанные(Команда)
	
	Если ЗначениеЗаполнено(LoadingVariant) Тогда
		ПоказатьВопрос(
		Новый ОписаниеОповещения("LoadData", 
		ЭтотОбъект, ),
		"Выполнить заполнение данных из Excel?", 
		РежимДиалогаВопрос.ДаНет,
		60,
		КодВозвратаДиалога.Нет,
		,
		КодВозвратаДиалога.Нет);
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Select loading variant");
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура LoadData(Результат, Параметр) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsx (*.xlsx)'") + "|*.xlsx" );
	НастройкиДиалога.Вставить("Rental", ЭтотОбъект);
	
	Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект);
	ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура LoadFile(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	АдресФайла = РезультатПомещенияФайлов.Хранение;
	РасширениеФайла = "xlsx";
	ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, AP)
	
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);
	
	ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла, AP);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла, AP)  
	
	ТекстОшибок = "";
	
	ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP);
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибок);
	КонецЕсли;
	
	//Элементы.ТаблицаДляЗагрузкиTR.Видимость = НЕ НетTR;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла)
	
	Connection = Новый COMОбъект("ADODB.Connection");
	СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + ПолноеИмяФайла + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
	
	Попытка 
		Connection.Open(СтрокаПодключения);	
	Исключение
		Попытка
			СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + ПолноеИмяФайла + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
			Connection.Open(СтрокаПодключения);
		Исключение
			ТекстОшибок = ТекстОшибок + ОписаниеОшибки();
		КонецПопытки;
	КонецПопытки;
	
	rs = Новый COMObject("ADODB.RecordSet");
	rs.ActiveConnection = Connection;
	rs = Connection.OpenSchema(20);
	
	МассивЛистов = Новый Массив;
	Лист = Неопределено;
	
	Пока rs.EOF() = 0 Цикл
		
		Если ЗначениеЗаполнено(Лист) И СтрНайти(rs.Fields("TABLE_NAME").Value, Лист) > 0 Тогда
			rs.MoveNext();
			Продолжить;
		КонецЕсли;
		
		Лист = rs.Fields("TABLE_NAME").Value;
		МассивЛистов.Добавить(Лист);
		
		rs.MoveNext();
		
	КонецЦикла;  
	
	ТаблицаExcel = Новый ТаблицаЗначений();
	ТаблицаExcel.Колонки.Добавить("НомерСтрокиФайла", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(5, 0)),"НомерСтрокиФайла");
	
	Для Каждого ЛистЭксель из МассивЛистов Цикл 
		
		sqlString = "select * from [" + ЛистЭксель + "]";
		rs.Close();
		rs.Open(sqlString);
		
		rs.MoveFirst();
		
		Если LoadingVariant = "TR/Trip" Тогда
			СвойстваСтруктуры = "Trip,TR,Sum";
		ИначеЕсли LoadingVariant = "Trip" Тогда
			СвойстваСтруктуры = "Trip,Sum";
		ИначеЕсли LoadingVariant = "TR" Тогда
			СвойстваСтруктуры = "TR,Sum";
		КонецЕсли;
		
		НомерСтроки = 0;
		Пока rs.EOF = 0 Цикл
			
			НомерСтроки = НомерСтроки + 1;
			
			Если НомерСтроки = 1 Тогда 
				
				СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок);
				
				Если Не ПустаяСтрока(ТекстОшибок) Тогда 
					Прервать;
				КонецЕсли;
				
				rs.MoveNext();
				Продолжить;
				
			КонецЕсли;
			
			СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
			
			//добавляем значение каждой ячейки файла в структуру значений
			Для Каждого ЭлементСтруктуры из СтруктураИменИНомеровКолонок Цикл 
				
				ЗначениеЯчейки = rs.Fields(ЭлементСтруктуры.Значение-1).Value;
				СтруктураЗначенийСтроки[ЭлементСтруктуры.Ключ] = СокрЛП(ЗначениеЯчейки);
				
			КонецЦикла;     			        						
			
			//добавляем новую структуру и пытаемся заполнить	
			Попытка
				
				НоваяСтрокаТаблицы = ТаблицаExcel.Добавить();
				
				ЗаполнитьЗначенияСвойств(НоваяСтрокаТаблицы, СтруктураЗначенийСтроки, СвойстваСтруктуры);
				
				НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
				
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось прочитать данные в строке №" + НомерСтроки + "'!";
			КонецПопытки;
			
			rs.MoveNext();
			
		КонецЦикла;
		
		Прервать;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
	Возврат ТаблицаExcel;
	
КонецФункции

&НаСервере
Функция ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Для Каждого Field из rs.Fields Цикл 
		
		ТекстЯчейки = СокрЛП(Field.Value);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли; 
		
		Если LoadingVariant = "TR/Trip" Тогда
			Если ТекстЯчейки = "Trip" Тогда
				СтруктураКолонокИИндексов.Trip = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "TR" Тогда
				СтруктураКолонокИИндексов.TR = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "Sum" Тогда
				СтруктураКолонокИИндексов.Sum = НомерКолонки;
			КонецЕсли;
		ИначеЕсли LoadingVariant = "Trip" Тогда
			Если ТекстЯчейки = "Trip" Тогда
				СтруктураКолонокИИндексов.Trip = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "Sum" Тогда
				СтруктураКолонокИИндексов.Sum = НомерКолонки;
			КонецЕсли;
		ИначеЕсли LoadingVariant = "TR" Тогда
			Если ТекстЯчейки = "TR" Тогда
				СтруктураКолонокИИндексов.TR = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "Sum" Тогда
				СтруктураКолонокИИндексов.Sum = НомерКолонки;
			КонецЕсли;
		КонецЕсли;
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла;
	
	Для Каждого КлючИЗначение Из СтруктураКолонокИИндексов Цикл
		
		Если КлючИЗначение.Значение = Неопределено Тогда
			ТекстОшибок = ТекстОшибок + "
			|необходимо проверить наличие колонки с данными '" + СтрЗаменить(КлючИЗначение.Ключ, "_", " ") + "'!";
		иначе
			ТаблицаExcel.Колонки.Добавить(КлючИЗначение.Ключ,,КлючИЗначение.Ключ);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтруктураКолонокИИндексов;
	
КонецФункции

&НаСервере	
Процедура ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP) 
	
	ТаблицаДляЗагрузки.Очистить();
	ТаблицаДляЗагрузки.Загрузить(ТаблицаExcel);
	
КонецПроцедуры

&НаСервере
Процедура CreateRentalCostsDocumentsНаСервере(МассивСозданныхДокументов)
	
		
	ЕстьОшибки = Ложь;
	
	ТЗ = ТаблицаДляЗагрузки.Выгрузить();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("НомераTR", ТаблицаДляЗагрузки.Выгрузить(,"TR"));
	Запрос.УстановитьПараметр("НомераTRIP", ТаблицаДляЗагрузки.Выгрузить(,"Trip"));
	
	Если LoadingVariant = "Trip" Тогда
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider КАК ServiceProvider,
		|	TripNonLawsonCompaniesParcels.Ссылка КАК TRIP,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TR
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка.Номер В(&НомераTRIP)
		|ИТОГИ ПО
		|	LegalEntity,
		|	ServiceProvider";
	ИначеЕсли LoadingVariant = "TR/Trip" Тогда
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider КАК ServiceProvider,
		|	TripNonLawsonCompaniesParcels.Ссылка КАК TRIP,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TR
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Номер В(&НомераTR)
		|	И TripNonLawsonCompaniesParcels.Ссылка.Номер В(&НомераTRIP)
		|ИТОГИ ПО
		|	LegalEntity,
		|	ServiceProvider";
	ИначеЕсли LoadingVariant = "TR" Тогда
		Запрос.Текст = "ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider КАК ServiceProvider,
		|	TripNonLawsonCompaniesParcels.Ссылка КАК TRIP,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TR
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Номер В(&НомераTR)
		|ИТОГИ ПО
		|	LegalEntity,
		|	ServiceProvider"
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаLegalEntity = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаLegalEntity.Следующий() Цикл
		// Вставить обработку выборки ВыборкаLegalEntity
		
		ВыборкаServiceProvider = ВыборкаLegalEntity.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаServiceProvider.Следующий() Цикл
			
			ДокRental = Документы.RentalTrucksCostsSums.СоздатьДокумент();
			ДокRental.Дата = ТекущаяДата();
			ДокRental.ДатаНачала = НачалоМесяца(ТекущаяДата());
			ДокRental.ДатаОкончания = КонецМесяца(ТекущаяДата());
			ДокRental.LegalEntity = ВыборкаLegalEntity.LegalEntity;
			ДокRental.ServiceProvider = ВыборкаServiceProvider.ServiceProvider;
			
			ВыборкаДетальныеЗаписи = ВыборкаServiceProvider.Выбрать();
			
			МассивTR = Новый Массив;
			МассивTRIP = Новый Массив;
			
			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				
				МассивTR.Добавить(ВыборкаДетальныеЗаписи.TR);
				МассивTRIP.Добавить(ВыборкаДетальныеЗаписи.TRIP);
				
			КонецЦикла;
			
			ЗапросПробегИВремя = Новый Запрос;
			ЗапросПробегИВремя.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
			|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
			|	TripNonLawsonCompaniesParcels.Ссылка.Transport КАК Transport,
			|	TripNonLawsonCompaniesStops.Mileage КАК Milage,
			|	TripNonLawsonCompaniesParcels.Ссылка.TotalActualDuration / 3600 КАК TotalActualDuration,
			|	TripNonLawsonCompaniesParcels.Ссылка.Transport.ServiceProvider КАК ServiceProvider,
			|	TripNonLawsonCompaniesParcels.Ссылка.Equipment КАК Equipment,
			|	TripNonLawsonCompaniesStops.ActualDepartureLocalTime КАК ActualDepartureLocalTime,
			|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
			|	StagesOfTripsNonLawsonCompanies.Stage,
			|	СУММА(TripNonLawsonCompaniesParcels.Parcel.GrossWeightKG / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels) КАК GrossWeightKG
			|ИЗ
			|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
			|		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops.Ссылка
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
			|		ПО TripNonLawsonCompaniesParcels.Ссылка = StagesOfTripsNonLawsonCompanies.Trip
			|ГДЕ
			|	TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport = &TypeOfTransport
			|	И TripNonLawsonCompaniesStops.Type = &Type
			|	И StagesOfTripsNonLawsonCompanies.Stage = &Stage
			|	И TripNonLawsonCompaniesParcels.Ссылка В(&МассивTRIP)
			|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest В(&МассивTR)
			|
			|СГРУППИРОВАТЬ ПО
			|	TripNonLawsonCompaniesParcels.Ссылка,
			|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest,
			|	TripNonLawsonCompaniesStops.ActualDepartureLocalTime,
			|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
			|	StagesOfTripsNonLawsonCompanies.Stage,
			|	TripNonLawsonCompaniesParcels.Ссылка.Transport,
			|	TripNonLawsonCompaniesStops.Mileage,
			|	TripNonLawsonCompaniesParcels.Ссылка.TotalActualDuration / 3600,
			|	TripNonLawsonCompaniesParcels.Ссылка.Transport.ServiceProvider,
			|	TripNonLawsonCompaniesParcels.Ссылка.Equipment
			|
			|УПОРЯДОЧИТЬ ПО
			|	TripNonLawsonCompaniesParcels.Ссылка.Дата";
			ЗапросПробегИВремя.УстановитьПараметр("TypeOfTransport", Перечисления.TypesOfTransport.Rental);
			ЗапросПробегИВремя.УстановитьПараметр("Type", Перечисления.StopsTypes.Destination);
			ЗапросПробегИВремя.УстановитьПараметр("Stage", Перечисления.TripNonLawsonCompaniesStages.Closed);
			ЗапросПробегИВремя.УстановитьПараметр("МассивTR", МассивTR);
			ЗапросПробегИВремя.УстановитьПараметр("МассивTRIP", МассивTRIP);
			РезультатПробегИВремя = ЗапросПробегИВремя.Выполнить().Выгрузить();
			
			РезультатПробегИВремяПоПоставщикам_Машинам = РезультатПробегИВремя.Скопировать();
			РезультатПробегИВремяПоПоставщикам_Машинам.Свернуть("ServiceProvider, Transport", "TotalActualDuration, Milage");	
			
			//Свернем по транспорту
			РезультатОбщийВесПоТС = РезультатПробегИВремя.Скопировать();
			РезультатОбщийВесПоТС.Свернуть("Transport", "GrossWeightKG");
			
			Трипы = РезультатПробегИВремя.Скопировать();
			Трипы.Свернуть("Trip, Transport");	
			РезультатBaseCost = ПолучитьBaseCosts(ТекущаяДата());
			
			//заполним Табличную часть документа
			i = 0;
			
			МассивОшибок = Новый Массив;
			Для Каждого Элемент из Трипы Цикл
				
				Отбор  = новый Структура;
				Отбор.Вставить("Trip", Элемент.Trip);
				РезультатПробегИВремяПоТрипам = РезультатПробегИВремя.Скопировать(Отбор);
				н = 0;
				Для каждого Строка из  РезультатПробегИВремяПоТрипам Цикл
					
					СтрокаТЧ = ДокRental.RentalTrucks.Добавить();
					СтрокаТЧ.DateTrip 			= Строка.Trip.Дата;
					СтрокаТЧ.TransportRequest 	= Строка.TransportRequest;
					СтрокаТЧ.Trip 				= Строка.Trip;
					СтрокаТЧ.LegalEntity 		= Строка.TransportRequest.LegalEntity;
					СтрокаТЧ.Segment 			= Строка.TransportRequest.CostCenter.Segment;
					СтрокаТЧ.AU 				= Строка.TransportRequest.CostCenter;
					СтрокаТЧ.Vehicle 			= Строка.Trip.EquipmentNo;
					СтрокаТЧ.Weight 			= ПосчитатьВесПоЗаявке(Строка); // Посчитаем общий вес по заявке
					СтрокаТЧ.Transport 			= Строка.Trip.Transport;

					TotalWeight = РезультатОбщийВесПоТС.Найти(Строка.Trip.Transport, "Transport").GrossWeightKG;
					
					СтрокаТЧ.Currency = Currency;
					
					СтруктураДляПоиска = Новый Структура();
					Если LoadingVariant = "TR/Trip" Тогда
						СтруктураДляПоиска.Вставить("Trip", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Строка.Trip, "Номер"));
						СтруктураДляПоиска.Вставить("TR", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Строка.TransportRequest, "Номер"));
					ИначеЕсли LoadingVariant = "Trip" Тогда
						СтруктураДляПоиска.Вставить("Trip", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Строка.Trip, "Номер"));
					ИначеЕсли LoadingVariant = "TR" Тогда
						СтруктураДляПоиска.Вставить("TR", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Строка.TransportRequest, "Номер"));
					КонецЕсли;
					
					Если НЕ LoadingVariant = "TR" Тогда
						Costs = ТЗ.НайтиСтроки(СтруктураДляПоиска);
						Если Costs.Количество() <> 0 Тогда
							СтрокаТЧ.Cost = 0;
							Для Каждого Элемент Из Costs Цикл
								СтрокаТЧ.Cost = СтрокаТЧ.Cost + Число(Элемент.Sum);
							КонецЦикла;
							СтрокаТЧ.Cost = СтрокаТЧ.Cost / РезультатПробегИВремяПоТрипам.Количество();
						КонецЕсли;
					Иначе
						Costs = ТЗ.Скопировать(СтруктураДляПоиска);
						КолВоСтрок = Costs.Количество();
						Если Costs.Количество() <> 0 Тогда
							Costs.Свернуть("TR","Sum");
							СтрокаТЧ.Cost = Число(Costs[0].Sum) / КолВоСтрок;
							Если Distribute Тогда
								КоличествоTripПоTR = ОпределитьКоличествоTrip(СтрокаТЧ.TransportRequest);
								Если КоличествоTripПоTR <> 0 Тогда
									СтрокаТЧ.Cost = СтрокаТЧ.Cost / КоличествоTripПоTR;
								КонецЕсли;
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
					
					СтрокаТЧ.Milage = Строка.Milage;
					BaseCost = ПосчитатьBaseCost(РезультатBaseCost, Строка.Trip.Transport); //получим BaseCost по Transport указанный в Trip
					Если BaseCost <> 0 Тогда
						СтрокаТЧ.BaseCost = BaseCost.MonthlyRate;
						СтрокаТЧ.BaseCostCurrency = BaseCost.Currency;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			
			Попытка
				ДокRental.Записать();
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("" + ДокRental.Номер);
				МассивСозданныхДокументов.Добавить(ДокRental.Ссылка);
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось записать документ");
			КонецПопытки;
			
		КонецЦикла;
	КонецЦикла;
		
	Если ЕстьОшибки Тогда
		Сообщить("File was not loaded.");
	Иначе
		//ЗафиксироватьТранзакцию();
		Сообщить("File was successfully loaded.");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура CreateRentalCostsDocuments(Команда)
	МассивСозданныхДокументов = Новый Массив;
	CreateRentalCostsDocumentsНаСервере(МассивСозданныхДокументов);
	
	Если МассивСозданныхДокументов.Количество() > 0 Тогда
		Для Каждого ДокумRental Из МассивСозданныхДокументов Цикл
			 ПоказатьЗначение(,ДокумRental);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьBaseCosts(ДатаЗапроса, Транспорт = Неопределено) 
	
	ЗапросBaseCost = Новый Запрос;
	ЗапросBaseCost.Текст = 
	"ВЫБРАТЬ
	|	TransportMonthlyRateСрезПоследних.Transport,
	|	TransportMonthlyRateСрезПоследних.MonthlyRate,
	|	TransportMonthlyRateСрезПоследних.Currency
	|ИЗ
	|	РегистрСведений.TransportMonthlyRate.СрезПоследних(
	|			&Дата,
	|			ВЫБОР
	|				КОГДА &Transport = НЕОПРЕДЕЛЕНО
	|					ТОГДА ИСТИНА
	|				ИНАЧЕ Transport = &Transport
	|			КОНЕЦ) КАК TransportMonthlyRateСрезПоследних
	|
	|УПОРЯДОЧИТЬ ПО
	|	TransportMonthlyRateСрезПоследних.Период УБЫВ";
	ЗапросBaseCost.УстановитьПараметр("Дата",		ДатаЗапроса);
	ЗапросBaseCost.УстановитьПараметр("Transport", 	Транспорт);
	
	Результат = ЗапросBaseCost.Выполнить().Выгрузить();
	
	Если ЗначениеЗаполнено(Транспорт) Тогда
		
		Ответ = Новый Структура("BaseCost, BaseCostCurrency", "", "");
		
		Если Результат.Количество() > 0 Тогда
			Ответ.BaseCost 			= Результат[0].MonthlyRate;
			Ответ.BaseCostCurrency 	= Результат[0].Currency;
		КонецЕсли;
		
		Возврат Ответ;
	Иначе
		Возврат Результат;	
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ПосчитатьBaseCost(BaseCost, Transport)
	
	Отбор = новый Структура;
	Отбор.Вставить("Transport", Transport);
	Результат = BaseCost.Скопировать(Отбор);
	Если Результат.Количество() > 0 Тогда
		Возврат Результат[0];
	Иначе
		Возврат 0;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ПосчитатьВесПоЗаявке(Строка)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Parcels", Строка.Trip.Parcels.Выгрузить());
	Запрос.УстановитьПараметр("TransportRequest", Строка.TransportRequest);
	
	Запрос.Текст =  "ВЫБРАТЬ
	|	Parcels.Parcel КАК Parcel,
	|	Parcels.NumOfParcels КАК NumOfParcels
	|ПОМЕСТИТЬ Parcels
	|ИЗ
	|	&Parcels КАК Parcels
	|;
	|ВЫБРАТЬ
	|	Сумма(TripParcels.Parcel.GrossWeightKG / TripParcels.Parcel.NumOfParcels * TripParcels.NumOfParcels) КАК GrossWeightKG
	|ИЗ
	|	Parcels КАК TripParcels
	|ГДЕ
	|	TripParcels.Parcel.TransportRequest = &TransportRequest";
	
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество()>0 тогда
		Возврат Результат[0].GrossWeightKG 
	Иначе
		Возврат 0
	КонецЕсли;	
	
КонецФункции

&НаСервере
Функция ПолучитьТарифBaseCosts(ДатаЗапроса, Транспорт = Неопределено, Объект) 
	
	ЗапросBaseCost = Новый Запрос;
	ЗапросBaseCost.Текст = 
	"ВЫБРАТЬ
	|	TransportMonthlyRateСрезПоследних.Transport,
	|	TransportMonthlyRateСрезПоследних.MonthlyRate КАК Cost,
	|	TransportMonthlyRateСрезПоследних.Currency
	|ИЗ
	|	РегистрСведений.TransportMonthlyRate.СрезПоследних(
	|			&Дата,
	|			ВЫБОР
	|				КОГДА &Transport = НЕОПРЕДЕЛЕНО
	|					ТОГДА ИСТИНА
	|				ИНАЧЕ Transport = &Transport
	|			КОНЕЦ) КАК TransportMonthlyRateСрезПоследних
	|
	|УПОРЯДОЧИТЬ ПО
	|	TransportMonthlyRateСрезПоследних.Период УБЫВ";
	ЗапросBaseCost.УстановитьПараметр("Дата",		ДатаЗапроса);
	ЗапросBaseCost.УстановитьПараметр("Transport", 	Транспорт);
	
	Результат = ЗапросBaseCost.Выполнить().Выгрузить();
	
	Если Результат.Количество() > 0 Тогда
		Возврат Результат[0];
	Иначе
		Возврат "";
	КонецЕсли;
	
	
КонецФункции

&НаСервере
Функция ПолучитьВалютуРубли()
	
	Возврат Справочники.Валюты.НайтиПоКоду("643");
	
КонецФункции


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Currency = ПолучитьВалютуРубли();
КонецПроцедуры


&НаКлиенте
Процедура LoadingVariantПриИзменении(Элемент)
	
	Если LoadingVariant = "TR" Тогда
		Элементы.Distribute.Видимость = Истина;
	Иначе
		Элементы.Distribute.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция  ОпределитьКоличествоTrip(TR)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ TripNonLawsonCompaniesParcels.Ссылка) КАК КолВо
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|ГДЕ
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TR";
	Запрос.УстановитьПараметр("TR", TR);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		возврат 0
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.КолВо;
	КонецЕсли;
	
КонецФункции