
//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВыбратьФайл();
	ЗаполнитьСписокЛистовЭкселя();
	ЗаполнитьПараметрыСтруктурыФайлаПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПараметрыСтруктурыФайлаПоУмолчанию()
	
	ColumnCode = 1;
	ColumnDescriptionEng = 2;
	ColumnSumCalculationMethod = 3;
	ColumnAllocationMethod = 4;
	ColumnAllocationArea = 5;
	
	FirstRowOfData = 2;
	LastRowOfData = 0;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыбратьФайл();
	ЗаполнитьСписокЛистовЭкселя();
	
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

&НаКлиенте
Процедура ЗаполнитьСписокЛистовЭкселя()
	
	Sheet = "";
	СписокЛистов = Новый Массив;
	Если ЗначениеЗаполнено(FullPath) Тогда
		Connection = Новый COMОбъект("ADODB.Connection");
		СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FullPath + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
		Попытка 
			Connection.Open(СтрокаПодключения);	
		Исключение
			Попытка
				СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FullPath + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
				Connection.Open(СтрокаПодключения);
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
		КонецПопытки;
		rs = Новый COMObject("ADODB.RecordSet");
		rs.ActiveConnection = Connection;
		rs = Connection.OpenSchema(20);
		Пока rs.EOF() = 0 Цикл
			Если rs.Fields("TABLE_NAME").Value <> "_xlnm#_FilterDatabase" Тогда
				СписокЛистов.Добавить(rs.Fields("TABLE_NAME").Value);
			КонецЕсли;
			rs.MoveNext();
		КонецЦикла;  
		rs.Close();
		Connection.Close();
	КонецЕсли;
	Элементы.Sheet.СписокВыбора.ЗагрузитьЗначения(СписокЛистов);
	Если СписокЛистов.Количество()>0 Тогда
		Sheet = СписокЛистов[0];
	Конецесли;		
	Если СписокЛистов.Количество() = 1 Или СписокЛистов.Количество() = 0 Тогда
		Элементы.Sheet.КнопкаСпискаВыбора = Ложь;
	Иначе
		Элементы.Sheet.КнопкаСпискаВыбора = Истина;
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
	
	ЗаполнитьТаблицуServicesИзФайлаXLS(Отказ, FullPath);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Состояние("Creating / updating services...");
	СоздатьИЗаполнитьServices(Отказ);
	
	Если Отказ Тогда
		Предупреждение("No service was loaded due to errors.
			|See them on the right pane.", 60);
	Иначе
		Предупреждение("Services were successfully loaded.", 60);	
	КонецЕсли;
	
КонецПроцедуры
                      
&НаКлиенте
Процедура ЗаполнитьТаблицуServicesИзФайлаXLS(Отказ, ПолноеИмяXLSФайла)
	
	// Открываем файл
	Connection = Новый COMОбъект("ADODB.Connection");
	СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FullPath + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
	Попытка 
		Connection.Open(СтрокаПодключения);	
	Исключение
		// если подключение не удалось, то пытаемся подключиться к файлу через Microsoft.Jet.OLEDB.4.0
		Попытка
			СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FullPath + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
            Connection.Open(СтрокаПодключения);
		Исключение
		    Сообщить(ОписаниеОшибки());
		КонецПопытки;
	КонецПопытки;
	rs = Новый COMObject("ADODB.RecordSet");
	rs.ActiveConnection = Connection;
	rs = Connection.OpenSchema(20);
	//rs.MoveFirst(); // Станем на 1 закладку
	sqlString = "select * from [" + Sheet + "]";
	rs.Close();
	rs.Open(sqlString);
	
	rs.MoveFirst();
	
	// пропуск заголока
	rs.Move(FirstRowOfData - 1);
	
	АвтоОпределениеКонца = LastRowOfData = 0;
	НомерТекущейСтроки = FirstRowOfData;
	//запоняем таб.документ пока не кончаться строки
	Пока ?(АвтоОпределениеКонца, rs.EOF = 0 И ЗначениеЗаполнено(rs.Fields(0).Value), НомерТекущейСтроки <= LastRowOfData) Цикл
		
		СтрокаТЗ = ТаблицаServices.Добавить();
		
		СтрокаТЗ.Code = СокрЛП(rs.Fields(ColumnCode - 1).Value);
		СтрокаТЗ.DescriptionEng = СокрЛП(rs.Fields(ColumnDescriptionEng - 1).Value);
		СтрокаТЗ.SumCalculationMethod = СокрЛП(rs.Fields(ColumnSumCalculationMethod - 1).Value);
		СтрокаТЗ.AllocationMethod = СокрЛП(rs.Fields(ColumnAllocationMethod - 1).Value);
		СтрокаТЗ.AllocationArea = СокрЛП(rs.Fields(ColumnAllocationArea - 1).Value);
		
		rs.MoveNext();
		НомерТекущейСтроки = НомерТекущейСтроки + 1;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура СоздатьИЗаполнитьServices(Отказ) 
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	Для Каждого ТекСтрока из ТаблицаServices Цикл 
		
		ТекСервис = Справочники.Services.НайтиПоКоду(ТекСтрока.Code,,GroupOfServices);
		Если Не ЗначениеЗаполнено(ТекСервис) Тогда
			ТекОбъект = Справочники.Services.СоздатьЭлемент();
			ТекОбъект.Код = ТекСтрока.Code;
			ТекОбъект.Родитель = GroupOfServices;
		Иначе
			ТекОбъект = ТекСервис.ПолучитьОбъект();
		КонецЕсли;
		
		ТекОбъект.DescriptionEng = ТекСтрока.DescriptionEng;
		ТекОбъект.SumCalculationMethod = ПолучитьSumCalculationMethod(ТекСтрока.SumCalculationMethod);
		ТекОбъект.AllocationMethod = ПолучитьAllocationMethod(ТекСтрока.AllocationMethod);
		ТекОбъект.AllocationArea = ПолучитьAllocationArea(ТекСтрока.AllocationArea);
		
		Попытка
			ТекОбъект.Записать();
		Исключение
			Отказ = Истина;
			ОтменитьТранзакцию();
			Возврат;
		КонецПопытки;
		
	КонецЦикла;
		
	ЗафиксироватьТранзакцию();

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьSumCalculationMethod(SumCalculationMethod)
	
	Если ВРег(SumCalculationMethod) = "STANDARD TARIFFS" Тогда
		Возврат Перечисления.SumCalculationMethods.StandardTariff;
	ИначеЕсли ВРег(SumCalculationMethod) = "COST-PLUS" Тогда
		Возврат Перечисления.SumCalculationMethods.CostPlus;
	ИначеЕсли Врег(SumCalculationMethod) = "QUOTED" Тогда
		Возврат Перечисления.SumCalculationMethods.Quoted;
	Иначе
		Возврат Перечисления.SumCalculationMethods.ПустаяСсылка();
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьAllocationArea(AllocationArea)
	
	Если ВРег(AllocationArea) = ВРег("Parcel") Тогда
		Возврат Перечисления.AllocationAreas.Parcel;
	ИначеЕсли ВРег(AllocationArea) = ВРег("Trip") Тогда
		Возврат Перечисления.AllocationAreas.Trip;
	ИначеЕсли Врег(AllocationArea) = ВРег("Shipment") Тогда
		Возврат Перечисления.AllocationAreas.Shipment;
	ИначеЕсли Врег(AllocationArea) = ВРег("CCD") Тогда
		Возврат Перечисления.AllocationAreas.CCD;
	ИначеЕсли Врег(AllocationArea) = ВРег("Items") Тогда
		Возврат Перечисления.AllocationAreas.InvoiceLines;
	Иначе
		Возврат Перечисления.AllocationAreas.ПустаяСсылка();
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьAllocationMethod(AllocationMethod)
	
	Если ВРег(AllocationMethod) = ВРег("By chargeable weight") Тогда
		Возврат Перечисления.AllocationMethods.ByChargeableWeight;
	ИначеЕсли ВРег(AllocationMethod) = ВРег("Equally") Тогда
		Возврат Перечисления.AllocationMethods.Equally;
	ИначеЕсли Врег(AllocationMethod) = ВРег("By Sum") Тогда
		Возврат Перечисления.AllocationMethods.BySum;
	Иначе
		Возврат Перечисления.AllocationMethods.ПустаяСсылка();
	КонецЕсли;
	
КонецФункции

