&НаКлиенте
Перем СоответствиеСинонимовИимен;

//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВыбратьФайл();
	ЗаполнитьСписокЛистовЭкселяИНомераКолонок();
	ЗаполнитьПараметрыСтруктурыФайлаПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПараметрыСтруктурыФайлаПоУмолчанию()
	
	FirstRowOfData = 2;
	LastRowOfData = 0;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыбратьФайл();
	ЗаполнитьСписокЛистовЭкселяИНомераКолонок();
	
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
Процедура ЗаполнитьСписокЛистовЭкселяИНомераКолонок()
	
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
		Если СписокЛистов.Количество()>0 Тогда
			Sheet = СписокЛистов[0];
			sqlString = "select top 1 * from [" + Sheet + "]";
			rs.Open(sqlString);
			ЗаполнитьНомераКолонок(rs);
			rs.Close();
		Конецесли;
		Connection.Close();
	КонецЕсли;
	Элементы.Sheet.СписокВыбора.ЗагрузитьЗначения(СписокЛистов);
	Если СписокЛистов.Количество() = 1 Или СписокЛистов.Количество() = 0 Тогда
		Элементы.Sheet.КнопкаСпискаВыбора = Ложь;
	Иначе
		Элементы.Sheet.КнопкаСпискаВыбора = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура SheetПриИзменении(Элемент)
	
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
		sqlString = "select top 1 * from [" + Sheet + "]";
		rs.Open(sqlString);
		ЗаполнитьНомераКолонок(rs);
		rs.Close();
		Connection.Close();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьНомераКолонок(rs)
	
	Если rs.EOF <> 0 Тогда
		Возврат;
	КонецЕсли;
	
	ColumnCode = 0;
	ColumnName = 0;
	
	Для ТекИндекс = 0 По rs.Fields.Count - 1 Цикл
		ИмяКолонки = СокрЛП(rs.Fields(ТекИндекс).Value);
		ИмяРеквизита = СоответствиеСинонимовИимен[ИмяКолонки];
		Если ИмяРеквизита <> Неопределено Тогда
			ЭтотОбъект["Column" + ИмяРеквизита] = ТекИндекс + 1;
		КонецЕсли;
	КонецЦикла;
	
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
	
	Если ColumnCode = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the column number!",
			, "Объект", "ColumnCode");
			Возврат;
	КонецЕсли;
	
	Отказ = Ложь;
	
	ЗаполнитьТаблицуДанныхИзФайлаXLS(Отказ, FullPath);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Состояние("Updating data...");
	ЗаполнитьLocations(Отказ);
	
	Если Отказ Тогда
		Предупреждение("No data was loaded due to errors.
			|See them on the right pane.", 60);
	Иначе
		Предупреждение("Locations were successfully loaded.", 60);	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуДанныхИзФайлаXLS(Отказ, ПолноеИмяXLSФайла)
	
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
	
	ТаблицаДанных.Очистить();
	
	//запоняем таб.документ пока не кончаться строки
	Пока ?(АвтоОпределениеКонца, rs.EOF = 0 И ЗначениеЗаполнено(rs.Fields(0).Value), НомерТекущейСтроки <= LastRowOfData) Цикл
		
		СтрокаТЗ = ТаблицаДанных.Добавить();
		
		СтрокаТЗ.Code = СокрЛП(rs.Fields(ColumnCode - 1).Value);
		Если ColumnName > 0 Тогда
			СтрокаТЗ.Name = СокрЛП(rs.Fields(ColumnName - 1).Value);
		КонецЕсли;
		Если ColumnInTMS > 0 Тогда
			СтрокаТЗ.InTMS = rs.Fields(ColumnInTMS - 1).Value;
		КонецЕсли;
		Если ColumnCountryCode > 0 Тогда
			СтрокаТЗ.CountryCode = СокрЛП(rs.Fields(ColumnCountryCode - 1).Value);
		КонецЕсли;
		Если ColumnRCACountry > 0 Тогда
			СтрокаТЗ.RCACountry = СокрЛП(rs.Fields(ColumnRCACountry - 1).Value);
		КонецЕсли;
		Если ColumnProcessLevel > 0 Тогда
			СтрокаТЗ.ProcessLevel = СокрЛП(rs.Fields(ColumnProcessLevel - 1).Value);
		КонецЕсли;
		Если ColumnCity > 0 Тогда
			СтрокаТЗ.City = СокрЛП(rs.Fields(ColumnCity - 1).Value);
		КонецЕсли;
		Если ColumnAddress1 > 0 Тогда
			СтрокаТЗ.Address1 = СокрЛП(rs.Fields(ColumnAddress1 - 1).Value);
		КонецЕсли;
		Если ColumnAddress2 > 0 Тогда
			СтрокаТЗ.Address2 = СокрЛП(rs.Fields(ColumnAddress2 - 1).Value);
		КонецЕсли;
		Если ColumnAddress3 > 0 Тогда
			СтрокаТЗ.Address3 = СокрЛП(rs.Fields(ColumnAddress3 - 1).Value);
		КонецЕсли;
		Если ColumnContactName > 0 Тогда
			СтрокаТЗ.ContactName = СокрЛП(rs.Fields(ColumnContactName - 1).Value);
		КонецЕсли;
		Если ColumnContactPhone > 0 Тогда
			СтрокаТЗ.ContactPhone = СокрЛП(rs.Fields(ColumnContactPhone - 1).Value);
		КонецЕсли;
		Если ColumnContactEMail > 0 Тогда
			СтрокаТЗ.ContactEMail = СокрЛП(rs.Fields(ColumnContactEMail - 1).Value);
		КонецЕсли;
		Если ColumnWarehouse > 0 Тогда
			СтрокаТЗ.Warehouse = rs.Fields(ColumnWarehouse - 1).Value;
		КонецЕсли;
		Если ColumnPort > 0 Тогда
			СтрокаТЗ.Port = rs.Fields(ColumnPort - 1).Value;
		КонецЕсли;
		Если ColumnAddressRus > 0 Тогда
			СтрокаТЗ.AddressRus = СокрЛП(rs.Fields(ColumnAddressRus - 1).Value);
		КонецЕсли;
		Если ColumnNameRus > 0 Тогда
			СтрокаТЗ.NameRus = СокрЛП(rs.Fields(ColumnNameRus - 1).Value);
		КонецЕсли;
		Если ColumnLongitude > 0 Тогда
			СтрокаТЗ.Longitude = rs.Fields(ColumnLongitude - 1).Value;
		КонецЕсли;
		Если ColumnLatitude > 0 Тогда
			СтрокаТЗ.Latitude = rs.Fields(ColumnLatitude - 1).Value;
		КонецЕсли;
		Если ColumnFacilityType > 0 Тогда
			СтрокаТЗ.FacilityType = rs.Fields(ColumnFacilityType - 1).Value;
		КонецЕсли;
		Если ColumnRegionProvince > 0 Тогда
			СтрокаТЗ.RegionProvince = rs.Fields(ColumnRegionProvince - 1).Value;
		КонецЕсли;

		rs.MoveNext();
		НомерТекущейСтроки = НомерТекущейСтроки + 1;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьLocations(Отказ) 
	
	СтруктураТекстовыхЗначений = СформироватьСтруктуруТекстовыхЗначений();
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	СтруктураТаблиц = ПолучитьСтруктуруТаблиц(СтруктураТекстовыхЗначений);
	
	Для Каждого ТекСтрока из ТаблицаДанных Цикл 
		
		НайденнаяСтрока = СтруктураТаблиц.ТаблицаLocations.Найти(ТекСтрока.Code, "LocationCode");
		Если НайденнаяСтрока = Неопределено Тогда
			// { RGS AGorlenko 18.11.2015 18:09:05 - по просьбе Марины Строковой создаем новые локации
			//ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to find Location by Code '" + ТекСтрока.Code + "'");
			//Отказ = Истина;
			//Продолжить;
			ТекОбъект = Справочники.Warehouses.СоздатьЭлемент();
			ТекОбъект.Код = ТекСтрока.Code;
		Иначе
			ТекОбъект = НайденнаяСтрока.Location.ПолучитьОбъект();
			// } RGS AGorlenko 18.11.2015 18:09:23 - по просьбе Марины Строковой создаем новые локации
		КонецЕсли;
		
		// { RGS AGorlenko 18.11.2015 18:09:05 - по просьбе Марины Строковой создаем новые локации
		//ТекОбъект = НайденнаяСтрока.Location.ПолучитьОбъект();
		// } RGS AGorlenko 18.11.2015 18:09:23 - по просьбе Марины Строковой создаем новые локации
		
		// установка ссылочных данных
		Если ColumnRCACountry > 0 Тогда
			Если Не ПустаяСтрока(ТекСтрока.RCACountry) Тогда
				НайденнаяСтрока = СтруктураТаблиц.ТаблицаRCACountries.Найти(ТекСтрока.RCACountry, "RCACountryCode");
				Если НайденнаяСтрока = Неопределено Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to find RCA country by Code '" + ТекСтрока.RCACountry + "'");
					Отказ = Истина;
					Продолжить;
				КонецЕсли;
				RCACountry = НайденнаяСтрока.RCACountry;
			Иначе
				RCACountry = Справочники.CountriesOfProcessLevels.ПустаяСсылка();
			КонецЕсли;
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.RCACountry, RCACountry);
		КонецЕсли;
		
		Если ColumnProcessLevel > 0 Тогда
			Если Не ПустаяСтрока(ТекСтрока.ProcessLevel) Тогда
				НайденнаяСтрока = СтруктураТаблиц.ТаблицаProcessLevels.Найти(ТекСтрока.ProcessLevel, "ProcessLevelCode");
				Если НайденнаяСтрока = Неопределено Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to find Process level by Code '" + ТекСтрока.ProcessLevel + "'");
					Отказ = Истина;
					Продолжить;
				КонецЕсли;
				ProcessLevel = НайденнаяСтрока.ProcessLevel;
			Иначе
				ProcessLevel = Справочники.ProcessLevels.ПустаяСсылка();
			КонецЕсли;
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ProcessLevel, ProcessLevel);
		КонецЕсли;
		
		Если ColumnCity > 0 Тогда
			Если Не ПустаяСтрока(ТекСтрока.City) Тогда
				НайденнаяСтрока = СтруктураТаблиц.ТаблицаCities.Найти(ТекСтрока.City, "CityCode");
				Если НайденнаяСтрока = Неопределено Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to find City by Code '" + ТекСтрока.City + "'");
					Отказ = Истина;
					Продолжить;
				КонецЕсли;
				City = НайденнаяСтрока.City;
			Иначе
				City = Справочники.Cities.ПустаяСсылка();
			КонецЕсли;
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.City, City);
		КонецЕсли;
		
		Если ColumnFacilityType > 0 Тогда
			Если Не ПустаяСтрока(ТекСтрока.FacilityType) Тогда
				НайденнаяСтрока = Справочники.FacilityTypes.НайтиПоНаименованию(СокрЛП(ТекСтрока.FacilityType));
				Если НайденнаяСтрока = Неопределено Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to find Facility type by Code '" + ТекСтрока.FacilityType + "'");
					Отказ = Истина;
					Продолжить;
				КонецЕсли;
				FacilityType = НайденнаяСтрока;
			Иначе
				FacilityType = Справочники.FacilityTypes.ПустаяСсылка();
			КонецЕсли;
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.FacilityType, FacilityType);
		КонецЕсли;

		Если ColumnRegionProvince > 0 Тогда
			Если Не ПустаяСтрока(ТекСтрока.RegionProvince) Тогда
				НайденнаяСтрока = Справочники.RegionProvince.НайтиПоКоду(СокрЛП(ТекСтрока.RegionProvince));
				Если НайденнаяСтрока = Неопределено Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to find Region (province) by Code '" + ТекСтрока.RegionProvince + "'");
					Отказ = Истина;
					Продолжить;
				КонецЕсли;
				RegionProvince = НайденнаяСтрока;
			Иначе
				RegionProvince = Справочники.RegionProvince.ПустаяСсылка();
			КонецЕсли;
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.RegionProvince, RegionProvince);
		КонецЕсли;
		
		// примитивные типы
		Если ColumnName > 0 Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Наименование, ТекСтрока.Name);
		КонецЕсли;
		Если ColumnInTMS Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.InTMS, ТекСтрока.InTMS);
		КонецЕсли;
		Если ColumnCountryCode Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.CountryCode, ТекСтрока.CountryCode);
		КонецЕсли;
		Если ColumnAddress1 Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Address1, ТекСтрока.Address1);
		КонецЕсли;
		Если ColumnAddress2 Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Address2, ТекСтрока.Address2);
		КонецЕсли;
		Если ColumnAddress3 Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Address3, ТекСтрока.Address3);
		КонецЕсли;
		Если ColumnContactName Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ContactName, ТекСтрока.ContactName);
		КонецЕсли;
		Если ColumnContactPhone Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ContactPhone, ТекСтрока.ContactPhone);
		КонецЕсли;
		Если ColumnContactEMail Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ContactEMail, ТекСтрока.ContactEMail);
		КонецЕсли;
		Если ColumnWarehouse Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Warehouse, ТекСтрока.Warehouse);
		КонецЕсли;
		Если ColumnPort Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Port, ТекСтрока.Port);
		КонецЕсли;
		Если ColumnAddressRus Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.AddressRus, ТекСтрока.AddressRus);
		КонецЕсли;
		Если ColumnNameRus Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.NameRus, ТекСтрока.NameRus);
		КонецЕсли;
		Если ColumnLongitude Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Longitude, ТекСтрока.Longitude);
		КонецЕсли;
		Если ColumnLatitude Тогда
			РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Latitude, ТекСтрока.Latitude);
		КонецЕсли;
		
		Если ТекОбъект.Модифицированность() Тогда
			Попытка
				ТекОбъект.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to save '" + СокрЛП(ТекОбъект.Код) + "'. See errors above.");
				Отказ = Истина;
				ОтменитьТранзакцию();
				Возврат;
			КонецПопытки;
		КонецЕсли;
		
	КонецЦикла;
	
	Если Отказ Тогда
		ОтменитьТранзакцию();
	Иначе
		ЗафиксироватьТранзакцию();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция СформироватьСтруктуруТекстовыхЗначений()
	
	СтруктураТекстовыхЗначений = Новый Структура("МассивLocationCode, МассивCountriesOfProcessLevelsCode, МассивProcessLevelCode, МассивCityCode");
	
	СтруктураТекстовыхЗначений.МассивLocationCode = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаДанных, "Code");
	Если ColumnRCACountry > 0 Тогда
		СтруктураТекстовыхЗначений.МассивCountriesOfProcessLevelsCode = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаДанных, "RCACountry");
	КонецЕсли;
	Если ColumnProcessLevel > 0 Тогда
		СтруктураТекстовыхЗначений.МассивProcessLevelCode = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаДанных, "ProcessLevel");
	КонецЕсли;
	Если ColumnCity > 0 Тогда
		СтруктураТекстовыхЗначений.МассивCityCode = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаДанных, "City");
	КонецЕсли;
	
	Возврат СтруктураТекстовыхЗначений;
	
КонецФункции

&НаСервере
Функция ПолучитьСтруктуруТаблиц(СтруктураТекстовыхЗначений)
	
	// Сформируем пакет запросов
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	СтруктураПараметров.Вставить("МассивLocationCode", СтруктураТекстовыхЗначений.МассивLocationCode);
	СтруктураТекстов.Вставить("Locations",
	    "ВЫБРАТЬ
	    |	Warehouses.Ссылка КАК Location,
	    |	ВЫРАЗИТЬ(Warehouses.Код КАК СТРОКА(50)) КАК LocationCode
	    |ИЗ
	    |	Справочник.Warehouses КАК Warehouses
	    |ГДЕ
	    |	НЕ Warehouses.ПометкаУдаления
	    |	И Warehouses.Код В(&МассивLocationCode)");
		
	Если ColumnRCACountry > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивCountriesOfProcessLevelsCode", СтруктураТекстовыхЗначений.МассивCountriesOfProcessLevelsCode);
		СтруктураТекстов.Вставить("RCACountries",
		    "ВЫБРАТЬ
		    |	CountriesOfProcessLevels.Ссылка КАК RCACountry,
		    |	ВЫРАЗИТЬ(CountriesOfProcessLevels.Код КАК СТРОКА(4)) КАК RCACountryCode
		    |ИЗ
		    |	Справочник.CountriesOfProcessLevels КАК CountriesOfProcessLevels
		    |ГДЕ
		    |	НЕ CountriesOfProcessLevels.ПометкаУдаления
		    |	И CountriesOfProcessLevels.Код В(&МассивCountriesOfProcessLevelsCode)");
		
	КонецЕсли;
	
	Если ColumnProcessLevel > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивProcessLevelCode", СтруктураТекстовыхЗначений.МассивProcessLevelCode);
		СтруктураТекстов.Вставить("ProcessLevels",
		    "ВЫБРАТЬ
		    |	ProcessLevels.Ссылка КАК ProcessLevel,
		    |	ВЫРАЗИТЬ(ProcessLevels.Код КАК СТРОКА(4)) КАК ProcessLevelCode
		    |ИЗ
		    |	Справочник.ProcessLevels КАК ProcessLevels
		    |ГДЕ
		    |	НЕ ProcessLevels.ПометкаУдаления
		    |	И ProcessLevels.Код В(&МассивProcessLevelCode)");
		
	КонецЕсли;
	
	Если ColumnCity > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивCityCode", СтруктураТекстовыхЗначений.МассивCityCode);
		СтруктураТекстов.Вставить("Cities",
		    "ВЫБРАТЬ
		    |	Cities.Ссылка КАК City,
		    |	ВЫРАЗИТЬ(Cities.Код КАК СТРОКА(30)) КАК CityCode
		    |ИЗ
		    |	Справочник.Cities КАК Cities
		    |ГДЕ
		    |	НЕ Cities.ПометкаУдаления
		    |	И Cities.Код В(&МассивCityCode)");
		
	КонецЕсли;
	
	// Выполним пакет запросов
	УстановитьПривилегированныйРежим(Истина);	
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	// Разберем результаты
	СтруктураОбъектовБазы = Новый Структура("ТаблицаLocations, ТаблицаRCACountries, ТаблицаProcessLevels, ТаблицаCities");
	
	// Locations
	СтруктураОбъектовБазы.Вставить("ТаблицаLocations", СтруктураРезультатов.Locations.Выгрузить());
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.ТаблицаLocations, "LocationCode");
	СтруктураОбъектовБазы.ТаблицаLocations.Индексы.Добавить("LocationCode");
	
	Если ColumnRCACountry > 0 Тогда
		СтруктураОбъектовБазы.Вставить("ТаблицаRCACountries", СтруктураРезультатов.RCACountries.Выгрузить());
		РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.ТаблицаRCACountries, "RCACountryCode");
		СтруктураОбъектовБазы.ТаблицаRCACountries.Индексы.Добавить("RCACountryCode");
	КонецЕсли;
	
	Если ColumnProcessLevel > 0 Тогда
		СтруктураОбъектовБазы.Вставить("ТаблицаProcessLevels", СтруктураРезультатов.ProcessLevels.Выгрузить());
		РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.ТаблицаProcessLevels, "ProcessLevelCode");
		СтруктураОбъектовБазы.ТаблицаProcessLevels.Индексы.Добавить("ProcessLevelCode");
	КонецЕсли;
	
	Если ColumnCity > 0 Тогда
		СтруктураОбъектовБазы.Вставить("ТаблицаCities", СтруктураРезультатов.Cities.Выгрузить());
		РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.ТаблицаCities, "CityCode");
		СтруктураОбъектовБазы.ТаблицаCities.Индексы.Добавить("CityCode");
	КонецЕсли;
	
	Возврат СтруктураОбъектовБазы;
	
КонецФункции


СоответствиеСинонимовИимен = Новый Соответствие;
СоответствиеСинонимовИимен.Вставить("Code", "Code");
СоответствиеСинонимовИимен.Вставить("Name", "Name");
СоответствиеСинонимовИимен.Вставить("In TMS", "InTMS");
СоответствиеСинонимовИимен.Вставить("Country code", "CountryCode");
СоответствиеСинонимовИимен.Вставить("RCA country", "RCACountry");
СоответствиеСинонимовИимен.Вставить("Process level", "ProcessLevel");
СоответствиеСинонимовИимен.Вставить("City", "City");
СоответствиеСинонимовИимен.Вставить("Address 1", "Address1");
СоответствиеСинонимовИимен.Вставить("Address 2", "Address2");
СоответствиеСинонимовИимен.Вставить("Address 3", "Address3");
СоответствиеСинонимовИимен.Вставить("Contact name", "ContactName");
СоответствиеСинонимовИимен.Вставить("Contact phone", "ContactPhone");
СоответствиеСинонимовИимен.Вставить("Contact e-mail", "ContactEMail");
СоответствиеСинонимовИимен.Вставить("Warehouse", "Warehouse");
СоответствиеСинонимовИимен.Вставить("Port", "Port");
СоответствиеСинонимовИимен.Вставить("Address (rus)", "AddressRus");
СоответствиеСинонимовИимен.Вставить("Name (rus)", "NameRus");
СоответствиеСинонимовИимен.Вставить("Region (province)", "RegionProvince");
СоответствиеСинонимовИимен.Вставить("Facility type", "FacilityType");





