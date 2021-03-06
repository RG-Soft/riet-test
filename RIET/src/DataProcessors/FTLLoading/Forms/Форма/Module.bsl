               	
//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	МассивUserSegments = ПараметрыСеанса.UserSegments;
	
	ДоступныВсеСегменты = РольДоступна("JobLogAdministrator") или РольДоступна("ПолныеПрава");
	Если Не ДоступныВсеСегменты Тогда
		Элементы.SegmentSubSegment.РедактированиеТекста = Ложь;
		Объект.SegmentSubSegment = МассивUserSegments[0];
		Если Не ЗначениеЗаполнено(Объект.SegmentSubSegment) Тогда 
			Сообщить("Нет прав доступа, для загрузки данных FTL нужен доступ к Сегменту!");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	РодительSegmentSubSegment = Объект.SegmentSubSegment.Родитель;
	
	СurrencySLB = Справочники.Валюты.НайтиПоНаименованию("SLB");
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьВсе(Команда)
	
	УстановитьФлажки(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура СброситьВыбор(Команда)
	
	УстановитьФлажки(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Признак)
	
	Для Каждого СтрокаТЧ Из Объект.JobsDetailes Цикл 
		
		ИдентификаторСтроки = СтрокаТЧ.ПолучитьИдентификатор();
		Если Элементы.JobsDetailes.ПроверитьСтроку(ИдентификаторСтроки) Тогда
			СтрокаТЧ.Грузить = Признак;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
         
&НаКлиенте
Процедура SegmentSubSegmentНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Не ДоступныВсеСегменты Тогда 
		
		СтандартнаяОбработка = Ложь;
		
		СписокSegmentов = ПолучитьСписокSegmentов(МассивUserSegments);
		
		Результат = ВыбратьИзСписка(СписокSegmentов, Элемент);
		Если Результат <> Неопределено Тогда
			Объект.SegmentSubSegment = Результат.Значение;
			РодительSegmentSubSegment = ПолучитьРодителяСегмента(Объект.SegmentSubSegment);
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСписокSegmentов(Segments)
	
	СписокSegmentов = Новый СписокЗначений;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Сегменты.Ссылка
	               |ИЗ
	               |	Справочник.Сегменты КАК Сегменты
	               |ГДЕ
	               |	НЕ Сегменты.ПометкаУдаления
	               |	И (Сегменты.Родитель В (&Segments)
	               |			ИЛИ Сегменты.Ссылка В (&Segments))
	               |	И Сегменты.ЭтоГруппа";
	
	Запрос.УстановитьПараметр("Segments", Segments);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СписокSegmentов.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	Возврат СписокSegmentов;

КонецФункции
     
&НаСервереБезКонтекста
Функция ПолучитьРодителяСегмента(SubSegment)
	
	Возврат SubSegment.Родитель;	
	
КонецФункции


//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Не ПодключитьРасширениеРаботыСФайлами() Тогда 
		Попытка
			УстановитьРасширениеРаботыСФайлами();
			ПодключитьРасширениеРаботыСФайлами();
		Исключение
			Сообщить("Failed to attach file system extension. 
			|Please install 1C to use FTL loading.");
			Возврат;
		КонецПопытки;
	КонецЕсли;
	
	ВыбратьФайл();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайл()
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогВыбораФайла.Фильтр						= "Files xlsx (*.xlsx)|*.xlsx|Files xls (*.xls)|*.xls";
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла	= Истина;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		
		FullPath = ДиалогВыбораФайла.ПолноеИмяФайла;
				
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура FullPathОткрытие(Элемент, СтандартнаяОбработка)
	
	ЗапуститьПриложение(FullPath);
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////////
// ЗАГРУЗКА

&НаКлиенте
Процедура Load(Команда)
	 		
	Если НЕ ЗначениеЗаполнено(FullPath) Тогда
		
		ВыбратьФайл();
		
		Если НЕ ЗначениеЗаполнено(FullPath) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Need to select file!",
				, "Объект", "FullPath");
				Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Ложь;
	            	
	ЗаполнитьТаблицуFTLИзФайлаXLS(Отказ, FullPath);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Объект.JobsDetailes.Очистить();
	ЗаполнитьJobsDetailes();
		
КонецПроцедуры
                      
&НаКлиенте
Процедура ЗаполнитьТаблицуFTLИзФайлаXLS(Отказ, ПолноеИмяXLSФайла)
	
	Excel = Неопределено;
	Workbooks = Неопределено;
	Worksheet = Неопределено;
	
	Состояние("Opening Excel...");
	Попытка
		Excel = Новый COMОбъект("Excel.Application");
	Исключение
		Сообщить("Failed to open Excel!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Отказ = Истина;
	КонецПопытки;
	
	Если НЕ Отказ Тогда
		
		Состояние("Opening file with Excel...");
		Workbooks = Excel.Workbooks;
		Попытка
			Workbook = Workbooks.Open(ПолноеИмяXLSФайла, , Истина);
		Исключение
			Excel.Quit();
			Сообщить("Failed to open file with Excel!
				|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
			Отказ = Истина;
		КонецПопытки;
		
	КонецЕсли;
	
	Если НЕ Отказ Тогда
		
		Состояние("Opening Excel sheet...");
		Попытка
			WorkSheet = Workbook.Worksheets(1);
		Исключение
			Сообщить("Failed to open First sheet!
				|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
			Отказ = Истина;
		КонецПопытки;
		
	КонецЕсли;
		
	Попытка
		ЗаполнитьТаблицуFTLИзWorksheet(Отказ, Worksheet);
	Исключение
		Сообщить("Failed to read file:
			|" + ОписаниеОшибки());
		Отказ = Истина;
	КонецПопытки;
	
	Состояние("Closing file...");
	Если Workbook <> Неопределено Тогда
		
		Попытка
			Workbook.Close(False);
		Исключение
			Сообщить("Failed to close Excel Workbook!
				|" + ОписаниеОшибки());
		КонецПопытки;
			
	КонецЕсли;
	
	Если Workbooks <> Неопределено Тогда
		
		Попытка
			Workbooks.Close();
		Исключение
			Сообщить("Failed to close Excel Workbooks!
				|" + ОписаниеОшибки());
		КонецПопытки;
		
	КонецЕсли;
	
	Если Excel <> Неопределено Тогда
		
		Состояние("Closing Excel...");
		Попытка
			Excel.Quit();
		Исключение
			Сообщить("Failed to close Excel!
				|" + ОписаниеОшибки());
		КонецПопытки;
			
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуFTLИзWorksheet(Отказ, Worksheet) 
	
	СвойстваСтруктуры = 
	"FTLTicketNo,JobEndDate,CANo,CAName,Customer,Well,TotalRevenue,Curr,PrimaryJobGroupSegment,SLBLocation,SLBEngineer,JobType";
	
	Состояние("Analyzing file...");
    СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(WorkSheet, СвойстваСтруктуры);
	Если СтруктураИменИНомеровКолонок = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	ТаблицаFTL.Очистить();

	Состояние("Reading file...");
	
	//перебираем все заполненные строки файла 
	СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
	КоличествоЯчеек = СтруктураЗначенийСтроки.Количество();
	НомерСтроки = 2;
	Пока Истина Цикл
		
		//добавляем значение каждой ячейки файла в структуру значений
		Для Каждого ЭлементСтруктуры из СтруктураИменИНомеровКолонок Цикл 
			
			ЗначениеЯчейки = СокрЛП(WorkSheet.Cells(НомерСтроки, ЭлементСтруктуры.Значение).Text);
			
			Если ЭлементСтруктуры.Ключ = "JobEndDate" 
				и ТипЗнч(WorkSheet.Cells(НомерСтроки, ЭлементСтруктуры.Значение).value) = Тип("Дата") Тогда 
				ЗначениеЯчейки = WorkSheet.Cells(НомерСтроки, ЭлементСтруктуры.Значение).value;
			КонецЕсли;
			
			СтруктураЗначенийСтроки[ЭлементСтруктуры.Ключ] = ЗначениеЯчейки;
			
		КонецЦикла;
		
		//проверяем, если все ячейки пустые - считаем, что последняя строка
		КолВоНезаполненныхЭлементовСтруктуры = ВернутьКолВоНезаполненныхЭлементовСтруктуры(СтруктураЗначенийСтроки);
		Если КоличествоЯчеек = КолВоНезаполненныхЭлементовСтруктуры Тогда 
			Прервать;
		КонецЕсли;
		
		//добавляем строку Таблицы и пытаемся заполнить	
			
		НоваяСтрокаТаблицы = ТаблицаFTL.Добавить();
		Для Каждого ЭлементСтруктурыЗначений из СтруктураЗначенийСтроки Цикл 
			НоваяСтрокаТаблицы[ЭлементСтруктурыЗначений.Ключ] = ЭлементСтруктурыЗначений.Значение;	
		КонецЦикла;
		НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
				
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;  
			
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСтруктуруИменИНомеровКолонок(WorkSheet, СвойстваСтруктуры)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	                                                    
	НомерКолонки = 1;
	Пока Истина Цикл
		
		ТекстЯчейки = СокрЛП(WorkSheet.Cells(1, НомерКолонки).Text);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли;                                   
		
		Если ТекстЯчейки = "FTL Ticket #" Тогда
			СтруктураКолонокИИндексов.FTLTicketNo = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Job End Date (GMT+1)" Тогда
			СтруктураКолонокИИндексов.JobEndDate = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "CA #" Тогда
			СтруктураКолонокИИндексов.CANo = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "CA Name" Тогда
			СтруктураКолонокИИндексов.CAName = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Customer" Тогда
			СтруктураКолонокИИндексов.Customer = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "Well" Тогда
			СтруктураКолонокИИндексов.Well = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "Total Revenue" Тогда
			СтруктураКолонокИИндексов.TotalRevenue = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "Curr" Тогда
			СтруктураКолонокИИндексов.Curr = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Primary Job Group Segment" Тогда
			СтруктураКолонокИИндексов.PrimaryJobGroupSegment = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "SLB Location" Тогда
			СтруктураКолонокИИндексов.SLBLocation = НомерКолонки;
	   	ИначеЕсли ТекстЯчейки = "SLB Engineer" Тогда
			СтруктураКолонокИИндексов.SLBEngineer = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Primary Job Type" Тогда
			СтруктураКолонокИИндексов.JobType = НомерКолонки;	
		КонецЕсли;  
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла; 
	
	Отказ = Ложь;
	Для Каждого КлючИЗначение Из СтруктураКолонокИИндексов Цикл
		
		Если НЕ ЗначениеЗаполнено(КлючИЗначение.Значение) Тогда
			Сообщить("Failed to find column " + КлючИЗначение.Ключ + "!");
			Отказ = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Если Отказ Тогда
		Возврат Неопределено;
	Иначе
		Возврат СтруктураКолонокИИндексов;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Функция ВернутьКолВоНезаполненныхЭлементовСтруктуры(СтруктураЗначенийСтроки)
	
	КолВоНезаполненныхЯчеек = 0;
	Для Каждого КлючИЗначение Из СтруктураЗначенийСтроки Цикл
		
		Если НЕ ЗначениеЗаполнено(КлючИЗначение.Значение) Тогда
			КолВоНезаполненныхЯчеек = КолВоНезаполненныхЯчеек + 1;
		КонецЕсли; 
		
	КонецЦикла;
	
	Возврат КолВоНезаполненныхЯчеек;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьJobsDetailes() 
	
	СтруктураОбъектовБазы = ПолучитьСтруктуруОбъектовБазы();
	СтруктураОтбораJob = Новый Структура("FTLNumber,Period");
		
	Для Каждого Стр из ТаблицаFTL Цикл 
		
		НоваяСтрока = Объект.JobsDetailes.Добавить();
		
		НоваяСтрока.FTLNumber    = Стр.FTLTicketNo;
		НоваяСтрока.CANumber     = Стр.CANo;
		НоваяСтрока.ContractName = Стр.CAName;
		НоваяСтрока.Client	     = Стр.Customer;
		НоваяСтрока.Well 		 = Стр.Well;
		НоваяСтрока.Type 		 = Стр.JobType;
		НоваяСтрока.FTLEngineer  = Стр.SLBEngineer;
				
		//Job end date
		Если ЗначениеЗаполнено(Стр.JobEndDate) Тогда
			Если ТипЗнч(Стр.JobEndDate) = Тип("Строка") Тогда 
				НоваяСтрока.JobEndDate = ПреобразоватьСтрокуВДату(Стр.JobEndDate, "Job end date", Стр.НомерСтрокиФайла);
			иначе
				НоваяСтрока.JobEndDate = Стр.JobEndDate;
			КонецЕсли;
		КонецЕсли;
		
		//PERIOD 
		Если ЗначениеЗаполнено(НоваяСтрока.JobEndDate) Тогда 
			НоваяСтрока.Period = ПолучитьPeriod(НоваяСтрока.JobEndDate);
		КонецЕсли;
		
		//Job
		СтруктураОтбораJob.FTLNumber = Стр.FTLTicketNo;
		СтруктураОтбораJob.Period = НоваяСтрока.Period;
		МассивСтрок = СтруктураОбъектовБазы.Jobs.НайтиСтроки(СтруктураОтбораJob);
		Если МассивСтрок.Количество() > 0  Тогда 
			НоваяСтрока.Job = МассивСтрок[0].Ссылка;
			НоваяСтрока.JobSegment = МассивСтрок[0].Segment;
		КонецЕсли;          		
		
		//Segment
		СтрокаSegment = СтруктураОбъектовБазы.Segments.Найти(Стр.PrimaryJobGroupSegment, "Код");
		Если СтрокаSegment <> Неопределено Тогда 
			НоваяСтрока.Segment = СтрокаSegment.Ссылка;
			
			Если Объект.SegmentSubSegment = НоваяСтрока.Segment Тогда 
				НоваяСтрока.Грузить = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
		//Location
		СтрокаLocation = СтруктураОбъектовБазы.Locations.Найти(Стр.SLBLocation, "Код");
		Если СтрокаLocation <> Неопределено Тогда 
			НоваяСтрока.Location     = СтрокаLocation.Ссылка;
			НоваяСтрока.LocationName = СтрокаLocation.GeoMarket;
		КонецЕсли;
		       				     				
		//Amount in contract currency
		Если ЗначениеЗаполнено(Стр.TotalRevenue) Тогда
			Попытка
				TotalRevenue = Число(Стр.TotalRevenue);
			Исключение
				Сообщить("Failed to convert """+Стр.TotalRevenue+""" in file's line №"+ Стр.НомерСтрокиФайла 
				+" to Amount in contract currency!
				|" + ОписаниеОшибки());
			КонецПопытки;
			НоваяСтрока.AmountInContractCurrency = TotalRevenue - ПолучитьСуммуTotalRevenueЗаПредыдущиеПериоды(Стр.FTLTicketNo, НоваяСтрока.Period);
		КонецЕсли;
		
		//Currency Of Contract
		СтрокаCurrency = СтруктураОбъектовБазы.Currencies.Найти(Стр.Curr, "Наименование");
		Если СтрокаCurrency <> Неопределено Тогда 
			НоваяСтрока.CurrencyOfContract = СтрокаCurrency.Ссылка;
		КонецЕсли;
		   				
	КонецЦикла;
		
КонецПроцедуры

&НаСервере
Функция ПолучитьСтруктуруОбъектовБазы()
		
	// Сформируем пакет запросов
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	МассивCurrencies     = Новый Массив;
	МассивSegments	     = Новый Массив;
	МассивLocations      = Новый Массив;
	МассивПользователей  = Новый Массив;
	
	Для Каждого Стр Из ТаблицаFTL Цикл
		
		Если ЗначениеЗаполнено(Стр.Curr) Тогда  
			Стр.Curr = СтрЗаменить(Стр.Curr, "RUB", "RUB");
			Если МассивCurrencies.Найти(Стр.Curr) = Неопределено Тогда
				МассивCurrencies.Добавить(Стр.Curr);
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Стр.PrimaryJobGroupSegment) И МассивSegments.Найти(Стр.PrimaryJobGroupSegment) = Неопределено Тогда
			МассивSegments.Добавить(Стр.PrimaryJobGroupSegment);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Стр.SLBLocation) И МассивLocations.Найти(Стр.SLBLocation) = Неопределено Тогда
			МассивLocations.Добавить(Стр.SLBLocation);
		КонецЕсли;
		  			
	КонецЦикла;
	
	СтруктураПараметров.Вставить("FTLNumbers", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекции(ТаблицаFTL, "FTLTicketNo"));
	СтруктураТекстов.Вставить("Jobs",
			"ВЫБРАТЬ
			|	Job.Ссылка,
			|	Job.FTLNumber,
			|	Job.Period,
			|	Job.Segment
			|ИЗ
			|	Документ.Job КАК Job
			|ГДЕ
			|	Job.FTLNumber В(&FTLNumbers)");
                                     			
	Если МассивCurrencies.Количество() > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивCurrencies", МассивCurrencies);
		СтруктураТекстов.Вставить("Currencies",
			"ВЫБРАТЬ
			|	Currencies.Ссылка,
			|	Currencies.Наименование
			|ИЗ
			|	Справочник.Валюты КАК Currencies
			|ГДЕ
			|	НЕ Currencies.ПометкаУдаления
			|	И Currencies.Наименование В(&МассивCurrencies)");
		
	КонецЕсли;
	
	Если МассивSegments.Количество() > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивSegments", МассивSegments);
		СтруктураТекстов.Вставить("Segments",
			"ВЫБРАТЬ
			|	Сегменты.Ссылка,
			|	Выразить(Сегменты.Код как Строка(5)) КАК Код
			|ИЗ
			|	Справочник.Сегменты КАК Сегменты
			|ГДЕ
			|	НЕ Сегменты.ПометкаУдаления
			|	И Сегменты.Код В(&МассивSegments)
			|	И Сегменты.ЭтоГруппа");
		
	КонецЕсли;
	
	Если МассивLocations.Количество() > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивLocations", МассивLocations);
		СтруктураТекстов.Вставить("Locations",
			"ВЫБРАТЬ
			|	ПодразделенияОрганизаций.Ссылка,
			|	ВЫРАЗИТЬ(ПодразделенияОрганизаций.Код КАК СТРОКА(10)) КАК Код,
			|	ПодразделенияОрганизаций.GeoMarket
			|ИЗ
			|	Справочник.ПодразделенияОрганизаций КАК ПодразделенияОрганизаций
			|ГДЕ
			|	НЕ ПодразделенияОрганизаций.ПометкаУдаления
			|	И ПодразделенияОрганизаций.Код В(&МассивLocations)");
		
	КонецЕсли;
      
	// Выполним пакет запросов
	УстановитьПривилегированныйРежим(Истина);	
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	// Разберем результаты
	СтруктураОбъектовБазы = Новый Структура("Jobs,Currencies,Segments,Locations,Пользователи");
	
	// Jobs	
	СтруктураОбъектовБазы.Вставить("Jobs", СтруктураРезультатов.Jobs.Выгрузить());
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.Jobs, "FTLNumber");
	СтруктураОбъектовБазы.Jobs.Индексы.Добавить("FTLNumber");

	// Currencies
	Если СтруктураРезультатов.Свойство("Currencies") Тогда
		СтруктураОбъектовБазы.Currencies = СтруктураРезультатов.Currencies.Выгрузить();
		РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.Currencies, "Наименование");
		СтруктураОбъектовБазы.Currencies.Индексы.Добавить("Наименование");
	КонецЕсли;
	
	// Segments
	Если СтруктураРезультатов.Свойство("Segments") Тогда
		СтруктураОбъектовБазы.Segments = СтруктураРезультатов.Segments.Выгрузить();
		РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.Segments, "Код");
		СтруктураОбъектовБазы.Segments.Индексы.Добавить("Код");
	КонецЕсли;
	
	// Locations
	Если СтруктураРезультатов.Свойство("Locations") Тогда
		СтруктураОбъектовБазы.Locations = СтруктураРезультатов.Locations.Выгрузить();
		РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.Locations, "Код");
		СтруктураОбъектовБазы.Locations.Индексы.Добавить("Код");
	КонецЕсли;
             		
	Возврат СтруктураОбъектовБазы;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПреобразоватьСтрокуВДату(Знач стрЗначение, ИмяРеквизита, НомерСтроки)
	
	Если НЕ ЗначениеЗаполнено(стрЗначение) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	ЗначениеДоИзменения = стрЗначение;
	
	День = Лев(стрЗначение, 2);
	
	Месяц = Сред(стрЗначение, 4, 3);
	Если Месяц = "JAN" или Месяц = "Jan" Тогда 
		Месяц = "01";
	ИначеЕсли Месяц = "FEB" или Месяц = "Feb" Тогда
		Месяц = "02";
	ИначеЕсли Месяц = "MAR" или Месяц = "Mar" Тогда
		Месяц = "03";
	ИначеЕсли Месяц = "APR" или Месяц = "Apr" Тогда
		Месяц = "04";
	ИначеЕсли Месяц = "MAY" или Месяц = "May" Тогда
		Месяц = "05";
	ИначеЕсли Месяц = "JUN" или Месяц = "Jun" Тогда
		Месяц = "06";
	ИначеЕсли Месяц = "JUL" или Месяц = "Jul" Тогда
		Месяц = "07";
	ИначеЕсли Месяц = "AUG" или Месяц = "Aug" Тогда
		Месяц = "08";
	ИначеЕсли Месяц = "SEP" или Месяц = "Sep" Тогда
		Месяц = "09";
	ИначеЕсли Месяц = "OCT" или Месяц = "Oct" Тогда
		Месяц = "10";
	ИначеЕсли Месяц = "NOV" или Месяц = "Nov" Тогда
		Месяц = "11";
	ИначеЕсли Месяц = "DEC" или Месяц = "Dec" Тогда
		Месяц = "12";
	КонецЕсли;
	
	Год = Сред(стрЗначение, 8, 4);
		  	
	Попытка
		Значение = Дата(Год+Месяц+День);
		Возврат Значение;
	Исключение
		Сообщить("Failed to convert """ + ЗначениеДоИзменения + """ in file's line №"+ НомерСтроки +" to "+ИмяРеквизита+"!
			|" + ОписаниеОшибки());
	КонецПопытки;
			
	Возврат Неопределено;
	
КонецФункции


//////////////////////////////////////////////////////////////////////////////////////
// СОЗДАНИЕ JOBS
                 
&НаКлиенте
Процедура CreateJobs(Команда)
	   	      		
	Если НЕ ЗначениеЗаполнено(Объект.SegmentSubSegment) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to select ""Segment/SubSegment"" for loading!",
			, "Объект.SegmentSubSegment");
		Возврат;
	КонецЕсли;
	        		
	Состояние("Creating / updating Jobs...");
	
	БылиОшибки = Ложь;
	CreateJobsНаСервере(БылиОшибки);
	
	Если БылиОшибки Тогда
		Предупреждение("There were errors.
			|See them on the right pane.", 60);
	Иначе
		Предупреждение("Jobs were successfully loaded.", 60);
	КонецЕсли;
	    			
КонецПроцедуры
     
&НаСервере
Процедура CreateJobsНаСервере(БылиОшибки)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТаблицаВыбранныхСтрок = Объект.JobsDetailes.Выгрузить(Новый Структура("Грузить", Истина));
	
	Для Каждого Стр из ТаблицаВыбранныхСтрок Цикл 
		 				
		Если ЗначениеЗаполнено(Стр.Job) Тогда 
			      						
			ДокументОбъект = Стр.Job.ПолучитьОбъект();
			
			Если ЗначениеЗаполнено(ДокументОбъект.Accountant) и Не РольДоступна("БухгалтерAR") Тогда
				БылиОшибки = Истина;
				Сообщить("Нельзя изменить Job в строке №"+ Стр.НомерСтроки +", документ заполнен бухгалтером AR.");
				Продолжить;
			КонецЕсли;
			ДокументОбъект.AU = Неопределено;
			ДокументОбъект.SubSegment = Неопределено;
			ДокументОбъект.SubSubSegment = Неопределено;
			
		иначе
			
			ЕстьТекущиеОшибки = Ложь;
			ПроверитьЗаполнениеОбязательныхРеквизитов(ЕстьТекущиеОшибки, Стр);
			
			Если ЕстьТекущиеОшибки Тогда 
				БылиОшибки = ЕстьТекущиеОшибки;
				Сообщить("Не удалось создать Job по данным строки №"+ Стр.НомерСтроки +"! См. ошибки выше.");
				Продолжить;
			КонецЕсли;
			
			ДокументОбъект = Документы.Job.СоздатьДокумент();
			
		КонецЕсли;
		
		ДокументОбъект.Дата    = Стр.JobEndDate;
		           				
		РодительSegment = Объект.SegmentSubSegment.Родитель;
		Если РодительSegment = Справочники.Сегменты.ПустаяСсылка() Тогда 
			ДокументОбъект.Segment    = Объект.SegmentSubSegment;
		Иначе 
			ДокументОбъект.Segment    = РодительSegment;
			ДокументОбъект.SubSegment = Объект.SegmentSubSegment;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(ДокументОбъект.CreatedBy) Тогда 
			ДокументОбъект.CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		КонецЕсли;
		ДокументОбъект.Engineer = Стр.FTLEngineer;
		
		Документы.Job.ЗаполнитьSubSegmentИСчетаLawsonПоУмолчаниюДляСегмента(ДокументОбъект);
		
		ЗаполнитьЗначенияСвойств(ДокументОбъект, Стр, 
		"Period,FTLNumber,Location,CANumber,ContractName,Client,Well,Type,AmountInContractCurrency,CurrencyOfContract,LocationName");
		
		ДокументОбъект.AU = ПолучитьAU(ДокументОбъект.Segment, ДокументОбъект.SubSegment, ДокументОбъект.Location, ДокументОбъект.LocationName);
		ДозаполнитьСуммы(ДокументОбъект, Стр.НомерСтроки);
		
		ДокументОбъект.ПометкаУдаления = Ложь;
		
		Попытка	
			ДокументОбъект.Записать();
		Исключение
			БылиОшибки = Истина;
			Сообщить("Не удалось сохранить Job по данным строки №"+ Стр.НомерСтроки +"!
			|" + ОписаниеОшибки());
		КонецПопытки;   
		
		//заполним Job в строке
		МассивСтрок = Объект.JobsDetailes.НайтиСтроки(Новый Структура("FTLNumber", Стр.FTLNumber));
		Если МассивСтрок.Количество() > 0 Тогда 
			МассивСтрок[0].Job = ДокументОбъект.Ссылка;
			МассивСтрок[0].JobSegment = ДокументОбъект.Segment;
		КонецЕсли;
		
	КонецЦикла;
	
	ЗаполнитьJobsDetailes();
	
КонецПроцедуры

&НаСервере
Процедура ДозаполнитьСуммы(ДокументОбъект, НомерСтроки)
	
	Если Не ЗначениеЗаполнено(ДокументОбъект.CurrencyOfContract) 
		или Не ЗначениеЗаполнено(ДокументОбъект.AmountInContractCurrency) Тогда
		Возврат;
	КонецЕсли;

	ДокументОбъект.СurrencyRate = ОбщегоНазначения.ПолучитьКурсВалюты(СurrencySLB, ДокументОбъект.Period).Курс;
	               		
	Если ДокументОбъект.CurrencyOfContract = Справочники.Валюты.НайтиПоНаименованию("USD") Тогда 
		ДокументОбъект.BaseСurrencyTotal = ДокументОбъект.AmountInContractCurrency;
	ИначеЕсли ДокументОбъект.CurrencyOfContract = Справочники.Валюты.НайтиПоКоду("643") Тогда
		ДокументОбъект.BaseСurrencyTotal = ?(ДокументОбъект.СurrencyRate = 0, 0,
									Окр(ДокументОбъект.AmountInContractCurrency / ДокументОбъект.СurrencyRate, 2)); 
	иначе
		СтруктураКурса = ОбщегоНазначения.ПолучитьКурсВалюты(ДокументОбъект.CurrencyOfContract, ДокументОбъект.Period);
		ДокументОбъект.BaseСurrencyTotal = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(ДокументОбъект.AmountInContractCurrency, ДокументОбъект.CurrencyOfContract, 
								СurrencySLB, СтруктураКурса.Курс, ДокументОбъект.СurrencyRate, СтруктураКурса.Кратность);
	КонецЕсли;
							
КонецПроцедуры

&НаСервере
Процедура ПроверитьЗаполнениеОбязательныхРеквизитов(ЕстьТекущиеОшибки, Стр)
	
	Если Не ЗначениеЗаполнено(Стр.FTLNumber) Тогда
		Сообщить("""FTL Number"" не заполнен в строке №"+ Стр.НомерСтроки+ "!");
		ЕстьТекущиеОшибки = Истина;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Стр.JobEndDate) Тогда
		Сообщить("""Job End Date"" не заполнен в строке №"+ Стр.НомерСтроки+ "!");
		ЕстьТекущиеОшибки = Истина;
	КонецЕсли;
	    	
КонецПроцедуры
   
&НаКлиенте
Процедура JobsDetailesJobEndDateПриИзменении(Элемент)
	
	ТекДанные = Элементы.JobsDetailes.ТекущиеДанные;

	Если Не ЗначениеЗаполнено(ТекДанные.Period) и ЗначениеЗаполнено(ТекДанные.JobEndDate) Тогда 
		ТекДанные.Period = ПолучитьPeriod(ТекДанные.JobEndDate); 
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура JobsDetailesPeriodРегулирование(Элемент, Направление, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ТекДанные = Элементы.JobsDetailes.ТекущиеДанные;
	
	ТекДанные.Period = НачалоМесяца(ДобавитьМесяц(ТекДанные.Period, Направление));
	
	ТекДанные.Job = ПолучитьJob(ТекДанные.FTLNumber, ТекДанные.Period);
	
КонецПроцедуры

&НаКлиенте
Процедура JobsDetailesLocationНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	ТекДанные = Элементы.JobsDetailes.ТекущиеДанные;
	СтандартнаяОбработка = Ложь;
	
	Если Не ЗначениеЗаполнено(ТекДанные.LocationName) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Заполните поле ""Location name""!",
			, "JobsDetailes[" + (ТекДанные.НомерСтроки - 1) + "].LocationName");
		Возврат;
	КонецЕсли;

	СписокLocation = ПолучитьСписокLocation(ТекДанные.LocationName);
	
	Результат = ВыбратьИзСписка(СписокLocation, Элемент);
	Если Результат <> Неопределено Тогда
		ТекДанные.Location = Результат.Значение;
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура JobsDetailesLocationNameПриИзменении(Элемент)
	
	ТекДанные = Элементы.JobsDetailes.ТекущиеДанные;
	
    ТекДанные.Location = ПолучитьLocationПоLocationName(ТекДанные.LocationName);
		
КонецПроцедуры

&НаКлиенте
Процедура JobsDetailesLocationNameНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ТекДанные = Элементы.JobsDetailes.ТекущиеДанные;
	СтандартнаяОбработка = Ложь;
	
	Результат = ОткрытьФормуМодально("Справочник.GeoMarkets.Форма.ФормаВыбора", Новый Структура("RCA"), ЭтаФорма);
	
	Если Результат <> Неопределено И Результат <> ТекДанные.LocationName Тогда
		ТекДанные.LocationName = Результат;
		
		ТекДанные.Location = ПолучитьLocationПоLocationName(ТекДанные.LocationName);
	КонецЕсли;
	
КонецПроцедуры


//ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ

&НаСервереБезКонтекста
Функция ПолучитьAU(Segment, SubSegment, Location, LocationName)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Segment", Segment);
	Запрос.Текст = "ВЫБРАТЬ
	|	КостЦентры.Ссылка
	|ИЗ
	|	Справочник.КостЦентры КАК КостЦентры
	|ГДЕ
	|	НЕ КостЦентры.ПометкаУдаления
	|	И КостЦентры.Segment = &Segment";
	
	Если ЗначениеЗаполнено(SubSegment) Тогда 
		Запрос.Текст = Запрос.Текст + "	
		|И КостЦентры.SubSegment = &SubSegment";
		Запрос.УстановитьПараметр("SubSegment", SubSegment);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Location) Тогда 
		Запрос.Текст = Запрос.Текст + "	
		|И КостЦентры.ПодразделениеОрганизации = &Location";
		Запрос.УстановитьПараметр("Location", Location);
	иначе 
		Запрос.Текст = Запрос.Текст + "	
		|И КостЦентры.ПодразделениеОрганизации.Geomarket = &LocationName";
		Запрос.УстановитьПараметр("LocationName", LocationName);
	КонецЕсли;
	       	
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() = 1 Тогда 
		Возврат Результат[0].Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;

КонецФункции

 &НаСервереБезКонтекста
Функция ПолучитьLocationПоLocationName(LocationName)
	
	Если ЗначениеЗаполнено(LocationName) Тогда 
		Возврат Справочники.ПодразделенияОрганизаций.НайтиПоРеквизиту("GeoMarket", LocationName);
	иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьСписокLocation(LocationName)
	
	СписокLocation = Новый СписокЗначений;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ПодразделенияОрганизаций.Ссылка
	               |ИЗ
	               |	Справочник.ПодразделенияОрганизаций КАК ПодразделенияОрганизаций
	               |ГДЕ
	               |	НЕ ПодразделенияОрганизаций.ПометкаУдаления
	               |	И ПодразделенияОрганизаций.GeoMarket = &LocationName";
	
	Запрос.УстановитьПараметр("LocationName", LocationName);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СписокLocation.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	Возврат СписокLocation;

КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьPeriod(JobEndDate)
	
	ЧислоМесяца = Число(Формат(JobEndDate,"ДФ=dd"));
	Period = ?(ЧислоМесяца > 25, КонецМесяца(JobEndDate)+1, НачалоМесяца(JobEndDate));
	
	Возврат Period;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьJob(FTLNumber, Period)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Job.Ссылка
	|ИЗ
	|	Документ.Job КАК Job
	|ГДЕ
	|	Job.FTLNumber = &FTLNumber
	|	И Job.Period = &Period";
	
	Запрос.УстановитьПараметр("FTLNumber", FTLNumber);
	Запрос.УстановитьПараметр("Period", Period);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда 
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьСуммуTotalRevenueЗаПредыдущиеПериоды(FTLNumber, Period)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(СУММА(Job.AmountInContractCurrency), 0) КАК AmountInContractCurrency
	               |ИЗ
	               |	Документ.Job КАК Job
	               |ГДЕ
	               |	Job.FTLNumber = &FTLNumber
	               |	И Job.Period < &Period
	               |	И Job.Segment.Код В(&МассивКодов)
	               |	И НЕ Job.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("FTLNumber", FTLNumber);
	Запрос.УстановитьПараметр("Period", Period);
	МассивКодов = Новый Массив;
	МассивКодов.Добавить("DBM");
	МассивКодов.Добавить("REW");
	Запрос.УстановитьПараметр("МассивКодов", МассивКодов);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда 
		Возврат Выборка.AmountInContractCurrency;
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции
 

