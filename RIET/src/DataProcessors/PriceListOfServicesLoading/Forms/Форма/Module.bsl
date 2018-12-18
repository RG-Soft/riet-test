 
//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВыбратьФайл();
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыбратьФайл();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайл()
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогВыбораФайла.Фильтр						= "Files xls (*.xls)|*.xls|Files xlsx (*.xlsx)|*.xlsx";
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла	= Истина;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		
		FullPath = ДиалогВыбораФайла.ПолноеИмяФайла;
				
	КонецЕсли;
		
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
	            	
	ПолучитьДанныеИзФайла(Отказ, FullPath);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если ТаблицаStandardTariffs.Количество() = 0
		И ТаблицаCostPlus.Количество() = 0
		И ТаблицаQuoted.Количество() = 0 Тогда
		
		Сообщить("At least one of the tables should be filled: Standard tariffs, Cost-plus or Quoted!");
		Возврат;
		
	КонецЕсли; 
	
	Состояние("Creating / updating Price list of services...");
	
	PriceList = ПолучитьДокументPriceListOfServicesПоНомеруИАгенту();
	
	Если ЗначениеЗаполнено(PriceList) Тогда 
		
		Ответ = Вопрос(
			"Price list of services for Agent '" + PriceListAgent+ "' with No. '" + PriceListNo + "' already exists.
			|Update it?",
			РежимДиалогаВопрос.ДаНет);
		
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат;
		КонецЕсли;

	КонецЕсли;	
		
	ЗаполнитьДокументPriceListOfServices(Отказ, PriceList);
	
	Если Отказ Тогда
		Предупреждение("Price list of services was not loaded due to errors.
			|See them on the right pane.", 60);
	Иначе
		Предупреждение("Price list of services was successfully loaded.", 60);	
	КонецЕсли;
	
КонецПроцедуры
                      
&НаКлиенте
Процедура ПолучитьДанныеИзФайла(Отказ, ПолноеИмяXLSФайла)
	
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
		
		ЗаполнитьТаблицыФормы(Отказ, Workbook);
		
	КонецЕсли;
				
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
Процедура ЗаполнитьТаблицыФормы(Отказ, Workbook)
	
	// Worksheet 1
	Состояние("Opening First Excel sheet...");
	Попытка
		WorkSheet1 = Workbook.Worksheets(1);
	Исключение
		Сообщить("Failed to open First sheet!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Отказ = Истина;
	КонецПопытки;
		   			
	Попытка
		ЗаполнитьHeaderИзWorksheet(Отказ, Worksheet1);
	Исключение
		Сообщить("Failed to read file:
			|" + ОписаниеОшибки());
		Отказ = Истина;
	КонецПопытки;
	
	// Worksheet 2
	Состояние("Opening Second Excel sheet...");
	Попытка
		WorkSheet2 = Workbook.Worksheets(2);
	Исключение
		Сообщить("Failed to open Second sheet!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Отказ = Истина;
	КонецПопытки;
	
	Попытка
		ЗаполнитьТаблицуStandardTariffsИзWorksheet(Отказ, WorkSheet2);
	Исключение
		Сообщить("Failed to read file:
			|" + ОписаниеОшибки());
		Отказ = Истина;
	КонецПопытки;
	
	// Worksheet 3
	Состояние("Opening Third Excel sheet...");
	Попытка
		WorkSheet3 = Workbook.Worksheets(3);
	Исключение
		Сообщить("Failed to open Third sheet!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Отказ = Истина;
	КонецПопытки;
	
	Попытка
		ЗаполнитьТаблицуCostPlusИзWorksheet(Отказ, WorkSheet3);
	Исключение
		Сообщить("Failed to read file:
			|" + ОписаниеОшибки());
		Отказ = Истина;
	КонецПопытки;

	// Worksheet 4
	Состояние("Opening Fourth Excel sheet...");
	Попытка
		WorkSheet4 = Workbook.Worksheets(4);
	Исключение
		Сообщить("Failed to open Fourth sheet!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Отказ = Истина;
	КонецПопытки;
	
	Попытка
		ЗаполнитьТаблицуQuotedИзWorksheet(Отказ, WorkSheet4);
	Исключение
		Сообщить("Failed to read file:
			|" + ОписаниеОшибки());
		Отказ = Истина;
	КонецПопытки;

КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьHeaderИзWorksheet(Отказ, Worksheet) 
	
	// перебираем ячейки первой и второй строки
	// No	            Agent	           Start date	Expire date	 Description	  Responsible
	// до 25 символов	код агента в 1с    дата	        дата	     до 30 символов	  alias
	
	// No 
	Если СокрЛП(WorkSheet.Cells(1, 1).Text) <> "No" Тогда 
		Сообщить("Failed to find column 'No' of price list (Worksheet 1)!");
		Отказ = Истина;		
	иначе
		
		No = СокрЛП(WorkSheet.Cells(2, 1).Text);
		
		Если Не ЗначениеЗаполнено(No) Тогда 
			Сообщить("'No' of price list is empty!");
			Отказ = Истина;		
		ИначеЕсли СтрДлина(No) > 25 Тогда 
			Сообщить("'No' of price list should not exceed 25 characters!");
			Отказ = Истина;
		иначе
			PriceListNo = No;
		КонецЕсли;
		
	КонецЕсли;
	
	// Agent
	Если СокрЛП(WorkSheet.Cells(1, 2).Text) <> "Agent" Тогда 
		Сообщить("Failed to find column 'Agent' of price list (Worksheet 1)!");
		Отказ = Истина;		
	иначе
		
		Agent = СокрЛП(WorkSheet.Cells(2, 2).Text);
		
		Если Не ЗначениеЗаполнено(Agent) Тогда 
			
			Сообщить("'Agent' of price list is empty!");
			Отказ = Истина;	
			
		иначе
			
			PriceListAgent = РГСофтСерверПовтИспСеанс.НайтиСсылку("Справочник", "Agents", "Код", Agent);
			
			Если Не ЗначениеЗаполнено(PriceListAgent) Тогда 
				Сообщить("Failed to find 'Agent' by code: '" + Agent + "'!");
				Отказ = Истина;	
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;

	// Start date
	Если СокрЛП(WorkSheet.Cells(1, 3).Text) <> "Start date" Тогда 
		Сообщить("Failed to find column 'Start date' of price list (Worksheet 1)!");
		Отказ = Истина;		
	иначе
		
		Start = WorkSheet.Cells(2, 3).Value;
		
		Если Не ЗначениеЗаполнено(Start) Тогда 
			
			Сообщить("'Start date' of price list is empty!");
			Отказ = Истина;	
			
		иначе
			
			Попытка
			    PriceListStartDate = ПолучитьДату(Start);
			Исключение 
				Сообщить("Failed to convert 'Start date' of price list to date!");
				Отказ = Истина;	
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Expire date
	Если СокрЛП(WorkSheet.Cells(1, 4).Text) <> "Expire date" Тогда 
		Сообщить("Failed to find column 'Expire date' of price list (Worksheet 1)!");
		Отказ = Истина;		
	иначе
		
		Expire = WorkSheet.Cells(2, 4).Value;
		
		Если Не ЗначениеЗаполнено(Expire) Тогда 
			
			Сообщить("'Expire date' of price list is empty!");
			Отказ = Истина;	
			
		иначе
			
			Попытка
			    PriceListExpireDate = ПолучитьДату(Expire);
			Исключение 
				Сообщить("Failed to convert 'Expire date' of price list to date!");
				Отказ = Истина;	
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Description 
	Если СокрЛП(WorkSheet.Cells(1, 5).Text) <> "Description" Тогда 
		Сообщить("Failed to find column 'Description' of price list (Worksheet 1)!");
		Отказ = Истина;		
	иначе
		PriceListDescription = СокрЛП(WorkSheet.Cells(2, 5).Text);
	КонецЕсли;

	// Responsible
	Если СокрЛП(WorkSheet.Cells(1, 6).Text) <> "Responsible" Тогда 
		Сообщить("Failed to find column 'Responsible' of price list (Worksheet 1)!");
		Отказ = Истина;		
	иначе
		
		Responsible = СокрЛП(WorkSheet.Cells(2, 6).Text);
		
		Если Не ЗначениеЗаполнено(Responsible) Тогда 
			
			Сообщить("'Responsible' of price list is empty!");
			Отказ = Истина;	
			
		иначе
			
			PriceListResponsible = РГСофтСерверПовтИспСеанс.НайтиСсылку("Справочник", "Пользователи", "Код", Responsible);
			
			Если Не ЗначениеЗаполнено(PriceListResponsible) Тогда 
				Сообщить("Failed to find User by alias: '" + Responsible + "'!");
				Отказ = Истина;	
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	     			
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуStandardTariffsИзWorksheet(Отказ, Worksheet) 
	
	//Service Code	    Description	     Price	Start date	 Expire date
	//код Service в 1с	без ограничения	 число	дата	     дата
        	
	ТаблицаStandardTariffs.Очистить();
	
	//проверяем ячейки
	Если СокрЛП(WorkSheet.Cells(1, 1).Text) <> "Service Code" Тогда 
		Сообщить("Failed to find column 'Service Code' of price list (Worksheet 2 Standard tariffs)!");
		Отказ = Истина;		
	КонецЕсли;	
	
    Если СокрЛП(WorkSheet.Cells(1, 2).Text) <> "Description" Тогда 
		Сообщить("Failed to find column 'Description' of price list (Worksheet 2 Standard tariffs)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 3).Text) <> "Price" Тогда 
		Сообщить("Failed to find column 'Price' of price list (Worksheet 2 Standard tariffs)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 4).Text) <> "Start date" Тогда 
		Сообщить("Failed to find column 'Start date' of price list (Worksheet 2 Standard tariffs)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 5).Text) <> "Expire date" Тогда 
		Сообщить("Failed to find column 'Expire date' of price list (Worksheet 2 Standard tariffs)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	// перебираем все заполненные строки файла 
	НомерСтроки = 2;
	Пока Истина Цикл
		
		ServiceCode = СокрЛП(WorkSheet.Cells(НомерСтроки, 1).Text);
		
		//проверяем, если ячейка пустая - считаем, что последняя строка
		Если Не ЗначениеЗаполнено(ServiceCode) Тогда 
			Прервать;
		КонецЕсли;
		
		//добавляем строку Таблицы и пытаемся заполнить	
		НоваяСтрокаТаблицы = ТаблицаStandardTariffs.Добавить();
		
		// Service
		НоваяСтрокаТаблицы.Service = РГСофтСерверПовтИспСеанс.НайтиСсылку("Справочник", "Services", "Код", ServiceCode);
		Если Не ЗначениеЗаполнено(НоваяСтрокаТаблицы.Service) Тогда 
			Сообщить("In line " + НомерСтроки + " of Standard Tariffs: failed to find Service by code: '" + ServiceCode + "'!");
			Отказ = Истина;	
		КонецЕсли;

		// Description
		НоваяСтрокаТаблицы.Description = СокрЛП(WorkSheet.Cells(НомерСтроки, 2).Text);
		Если Не ЗначениеЗаполнено(НоваяСтрокаТаблицы.Description) Тогда 
			Сообщить("In line " + НомерСтроки + " of Standard Tariffs: Description is empty!");
			Отказ = Истина;	
		КонецЕсли;

		// Price 
		Price = WorkSheet.Cells(НомерСтроки, 3).Value;
		Если Не ЗначениеЗаполнено(Price) Тогда 
			Сообщить("In line " + НомерСтроки + " of Standard Tariffs: Price is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.Price = Число(Price);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Standard Tariffs: failed to convert Price to numeric!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;

		// Start date
		StartDate = WorkSheet.Cells(НомерСтроки, 4).Value;
		Если Не ЗначениеЗаполнено(StartDate) Тогда 
			Сообщить("In line " + НомерСтроки + " of Standard Tariffs: Start date is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.StartDate = ПолучитьДату(StartDate);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Standard Tariffs: failed to convert Start date to date!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		// Expire date
		ExpireDate = WorkSheet.Cells(НомерСтроки, 5).Value;
		Если Не ЗначениеЗаполнено(ExpireDate) Тогда 
			Сообщить("In line " + НомерСтроки + " of Standard Tariffs: Expire date is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.ExpireDate = ПолучитьДату(ExpireDate);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Standard Tariffs: failed to convert Expire date to date!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
		
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;  
			
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуCostPlusИзWorksheet(Отказ, Worksheet) 
	
	//Service Code	    Description	     Percent	Start date	 Expire date
	//код Service в 1с	без ограничения	 число	    дата	     дата
        	
	ТаблицаCostPlus.Очистить();
	
	//проверяем ячейки
	Если СокрЛП(WorkSheet.Cells(1, 1).Text) <> "Service Code" Тогда 
		Сообщить("Failed to find column 'Service Code' of price list (Worksheet 3 Cost-plus)!");
		Отказ = Истина;		
	КонецЕсли;	
	
    Если СокрЛП(WorkSheet.Cells(1, 2).Text) <> "Description" Тогда 
		Сообщить("Failed to find column 'Description' of price list (Worksheet 3 Cost-plus)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 3).Text) <> "Percent" Тогда 
		Сообщить("Failed to find column 'Percent' of price list (Worksheet 3 Cost-plus)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 4).Text) <> "Start date" Тогда 
		Сообщить("Failed to find column 'Start date' of price list (Worksheet 3 Cost-plus)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 5).Text) <> "Expire date" Тогда 
		Сообщить("Failed to find column 'Expire date' of price list (Worksheet 3 Cost-plus)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	// перебираем все заполненные строки файла 
	НомерСтроки = 2;
	Пока Истина Цикл
		
		ServiceCode = СокрЛП(WorkSheet.Cells(НомерСтроки, 1).Text);
		
		//проверяем, если ячейка пустая - считаем, что последняя строка
		Если Не ЗначениеЗаполнено(ServiceCode) Тогда 
			Прервать;
		КонецЕсли;
		
		//добавляем строку Таблицы и пытаемся заполнить	
		НоваяСтрокаТаблицы = ТаблицаCostPlus.Добавить();
		
		// Service
		НоваяСтрокаТаблицы.Service = РГСофтСерверПовтИспСеанс.НайтиСсылку("Справочник", "Services", "Код", ServiceCode);
		Если Не ЗначениеЗаполнено(НоваяСтрокаТаблицы.Service) Тогда 
			Сообщить("In line " + НомерСтроки + " of Cost-plus: failed to find Service by code: '" + ServiceCode + "'!");
			Отказ = Истина;	
		КонецЕсли;

		// Description
		НоваяСтрокаТаблицы.Description = СокрЛП(WorkSheet.Cells(НомерСтроки, 2).Text);
		Если Не ЗначениеЗаполнено(НоваяСтрокаТаблицы.Description) Тогда 
			Сообщить("In line " + НомерСтроки + " of Cost-plus: Description is empty!");
			Отказ = Истина;	
		КонецЕсли;

		// Percent 
		Percent = WorkSheet.Cells(НомерСтроки, 3).Value;
		Если Не ЗначениеЗаполнено(Percent) Тогда 
			Сообщить("In line " + НомерСтроки + " of Cost-plus: Percent is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.Percent = Число(Percent);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Cost-plus: failed to convert Percent to numeric!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;

		// Start date
		StartDate = WorkSheet.Cells(НомерСтроки, 4).Value;
		Если Не ЗначениеЗаполнено(StartDate) Тогда 
			Сообщить("In line " + НомерСтроки + " of Cost-plus: Start date is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.StartDate = ПолучитьДату(StartDate);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Cost-plus: failed to convert Start date to date!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		// Expire date
		ExpireDate = WorkSheet.Cells(НомерСтроки, 5).Value;
		Если Не ЗначениеЗаполнено(ExpireDate) Тогда 
			Сообщить("In line " + НомерСтроки + " of Cost-plus: Expire date is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.ExpireDate = ПолучитьДату(ExpireDate);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Cost-plus: failed to convert Expire date to date!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
		
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;  
			
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуQuotedИзWorksheet(Отказ, Worksheet) 
	
	//Service Code	    Description	     Start date	 Expire date
	//код Service в 1с	без ограничения	 дата	     дата
        	
	ТаблицаQuoted.Очистить();
	
	//проверяем ячейки
	Если СокрЛП(WorkSheet.Cells(1, 1).Text) <> "Service Code" Тогда 
		Сообщить("Failed to find column 'Service Code' of price list (Worksheet 4 Quoted)!");
		Отказ = Истина;		
	КонецЕсли;	
	
    Если СокрЛП(WorkSheet.Cells(1, 2).Text) <> "Description" Тогда 
		Сообщить("Failed to find column 'Description' of price list (Worksheet 4 Quoted)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 3).Text) <> "Start date" Тогда 
		Сообщить("Failed to find column 'Start date' of price list (Worksheet 4 Quoted)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если СокрЛП(WorkSheet.Cells(1, 4).Text) <> "Expire date" Тогда 
		Сообщить("Failed to find column 'Expire date' of price list (Worksheet 4 Quoted)!");
		Отказ = Истина;		
	КонецЕсли;
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	// перебираем все заполненные строки файла 
	НомерСтроки = 2;
	Пока Истина Цикл
		
		ServiceCode = СокрЛП(WorkSheet.Cells(НомерСтроки, 1).Text);
		
		//проверяем, если ячейка пустая - считаем, что последняя строка
		Если Не ЗначениеЗаполнено(ServiceCode) Тогда 
			Прервать;
		КонецЕсли;
		
		//добавляем строку Таблицы и пытаемся заполнить	
		НоваяСтрокаТаблицы = ТаблицаQuoted.Добавить();
		
		// Service
		НоваяСтрокаТаблицы.Service = РГСофтСерверПовтИспСеанс.НайтиСсылку("Справочник", "Services", "Код", ServiceCode);
		Если Не ЗначениеЗаполнено(НоваяСтрокаТаблицы.Service) Тогда 
			Сообщить("In line " + НомерСтроки + " of Quoted: failed to find Service by code: '" + ServiceCode + "'!");
			Отказ = Истина;	
		КонецЕсли;

		// Description
		НоваяСтрокаТаблицы.Description = СокрЛП(WorkSheet.Cells(НомерСтроки, 2).Text);
		Если Не ЗначениеЗаполнено(НоваяСтрокаТаблицы.Description) Тогда 
			Сообщить("In line " + НомерСтроки + " of Quoted: Description is empty!");
			Отказ = Истина;	
		КонецЕсли;
           		
		// Start date
		StartDate = WorkSheet.Cells(НомерСтроки, 3).Value;
		Если Не ЗначениеЗаполнено(StartDate) Тогда 
			Сообщить("In line " + НомерСтроки + " of Quoted: Start date is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.StartDate = ПолучитьДату(StartDate);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Quoted: failed to convert Start date to date!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		// Expire date
		ExpireDate = WorkSheet.Cells(НомерСтроки, 4).Value;
		Если Не ЗначениеЗаполнено(ExpireDate) Тогда 
			Сообщить("In line " + НомерСтроки + " of Quoted: Expire date is empty!");
			Отказ = Истина;	
		иначе
			Попытка
				НоваяСтрокаТаблицы.ExpireDate = ПолучитьДату(ExpireDate);
			Исключение
				Сообщить("In line " + НомерСтроки + " of Quoted: failed to convert Expire date to date!");
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
		
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;  
			
КонецПроцедуры

// ЗАПОЛНЕНИЕ

&НаСервере
Функция ПолучитьДокументPriceListOfServicesПоНомеруИАгенту() 

	PriceList = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Agent", PriceListAgent);
	Запрос.УстановитьПараметр("Номер", PriceListNo);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	PriceListOfServices.Ссылка КАК PriceList
	|ИЗ
	|	Документ.PriceListOfServices КАК PriceListOfServices
	|ГДЕ
	|	PriceListOfServices.Agent = &Agent
	|	И PriceListOfServices.Номер = &Номер";
	  	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		PriceList = Выборка.PriceList;
	КонецЕсли;
	
	Возврат PriceList;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьДокументPriceListOfServices(Отказ, PriceList) 
        		
	Если ЗначениеЗаполнено(PriceList) Тогда 
		PriceListОбъект = PriceList.ПолучитьОбъект(); 
	Иначе 
		PriceListОбъект = Документы.PriceListOfServices.СоздатьДокумент();
	КонецЕсли;
	
	PriceListОбъект.Номер = PriceListNo;
	PriceListОбъект.Agent = PriceListAgent;
	PriceListОбъект.Дата = PriceListStartDate;
	PriceListОбъект.ExpireDate = PriceListExpireDate;
    PriceListОбъект.Description = PriceListDescription;
	PriceListОбъект.Responsible = PriceListResponsible;
	
	PriceListОбъект.LastModified = ТекущаяДата();
	PriceListОбъект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
     	
	PriceListОбъект.StandardTariffs.Очистить();
	Для Каждого СтрокаStandardTariffs из ТаблицаStandardTariffs Цикл 
		НоваяСтрокаStandardTariffs = PriceListОбъект.StandardTariffs.Добавить();
		НоваяСтрокаStandardTariffs.Service = СтрокаStandardTariffs.Service;
		НоваяСтрокаStandardTariffs.Description = СтрокаStandardTariffs.Description;
		НоваяСтрокаStandardTariffs.Price = СтрокаStandardTariffs.Price;
		НоваяСтрокаStandardTariffs.StartDate = СтрокаStandardTariffs.StartDate;
		НоваяСтрокаStandardTariffs.ExpireDate = СтрокаStandardTariffs.ExpireDate;
	КонецЦикла;
	
	PriceListОбъект.CostPlus.Очистить();
	Для Каждого СтрокаCostPlus из ТаблицаCostPlus Цикл 
		НоваяСтрокаCostPlus = PriceListОбъект.CostPlus.Добавить();
		НоваяСтрокаCostPlus.Service = СтрокаCostPlus.Service;
		НоваяСтрокаCostPlus.Description = СтрокаCostPlus.Description;
		НоваяСтрокаCostPlus.Percent = СтрокаCostPlus.Percent;
		НоваяСтрокаCostPlus.StartDate = СтрокаCostPlus.StartDate;
		НоваяСтрокаCostPlus.ExpireDate = СтрокаCostPlus.ExpireDate;
	КонецЦикла;
	
	PriceListОбъект.Quoted.Очистить();
	Для Каждого СтрокаQuoted из ТаблицаQuoted Цикл 
		НоваяСтрокаQuoted = PriceListОбъект.Quoted.Добавить();
		НоваяСтрокаQuoted.Service = СтрокаQuoted.Service;
		НоваяСтрокаQuoted.Description = СтрокаQuoted.Description;
		НоваяСтрокаQuoted.StartDate = СтрокаQuoted.StartDate;
		НоваяСтрокаQuoted.ExpireDate = СтрокаQuoted.ExpireDate;
	КонецЦикла;	 
	
	Попытка
		PriceListОбъект.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
		Сообщить("Failed to post '" + PriceListОбъект + "'!
			|" + ОписаниеОшибки());
		Отказ = Истина; 
	КонецПопытки;
		
КонецПроцедуры

&НаСервере
Функция ПолучитьДату(Строка)
	
	Если ТипЗнч(Строка) = Тип("Дата") Тогда
		Возврат Строка;
	КонецЕсли;
	
	СтрокаДата = СокрЛП(Строка);
	СтрокаДата = Прав(СтрокаДата, 4) + Сред(СтрокаДата, 4, 2) + Лев(СтрокаДата, 2);
		       		
	Возврат	Дата(СтрокаДата);
	
КонецФункции


