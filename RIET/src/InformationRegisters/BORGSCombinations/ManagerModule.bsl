Процедура ЗагрузитьДанные(АдресФайла, РасширениеФайла, AP) Экспорт
		
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);
	
	ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла, AP);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
	
КонецПроцедуры

Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла, AP)  
	
	ТекстОшибок = "";
	
	ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP);
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("" + ТекстОшибок);
	КонецЕсли;
	
КонецПроцедуры

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
		
		СвойстваСтруктуры = "BORG,ParentCompany,AU,Country";
		
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
		
		//Прервать;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
	Возврат ТаблицаExcel;
	
КонецФункции

Функция ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Для Каждого Field из rs.Fields Цикл 
		
		ТекстЯчейки = СокрЛП(Field.Value);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли;
		
		Если Найти(ТекстЯчейки, "Borg Name") Тогда
			СтруктураКолонокИИндексов.BORG = НомерКолонки;
		ИначеЕсли Найти(ТекстЯчейки, "Company Code") Тогда
			СтруктураКолонокИИндексов.ParentCompany = НомерКолонки;
		ИначеЕсли Найти(ТекстЯчейки, "Cost Center List") > 0 Тогда
			СтруктураКолонокИИндексов.AU = НомерКолонки;
		ИначеЕсли Найти(ТекстЯчейки, "Country") > 0 Тогда
			СтруктураКолонокИИндексов.Country = НомерКолонки;
		КонецЕсли;
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла; 
	
	Для Каждого КлючИЗначение Из СтруктураКолонокИИндексов Цикл
		
		Если КлючИЗначение.Значение = Неопределено Тогда
			ТекстОшибок = ТекстОшибок + "
			|необходимо проверить наличие колонки с данными '" + СтрЗаменить(КлючИЗначение.Ключ, "_", " ") + "'!";
		иначе
			Если ТаблицаExcel.Колонки.Найти(КлючИЗначение.Ключ) = Неопределено Тогда
				ТаблицаExcel.Колонки.Добавить(КлючИЗначение.Ключ,,КлючИЗначение.Ключ);
			КонецЕсли;				
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтруктураКолонокИИндексов;
	
КонецФункции

Процедура ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP) 
	
	Набор = РегистрыСведений.BORGSCombinations.СоздатьНаборЗаписей();
	Для Каждого Элемент Из ТаблицаExcel Цикл
		
		Если ПустаяСтрока(Элемент.BORG) И ПустаяСтрока(Элемент.ParentCompany) И ПустаяСтрока(Элемент.AU) Тогда
			Продолжить;
		КонецЕсли;	
		
		КостЦентры = НайтиAUs(Лев(Элемент.AU, СтрНайти(Элемент.AU, ":")-1));
		
		Компании 	= НайтиКомпанию(Элемент);
		BORG 		= Справочники.BORGs.НайтиПоКоду(Лев(Элемент.BORG, 4));
		
		Если НЕ ЗначениеЗаполнено(BORG) Тогда
			Сообщить("Не удалось найти BORG по коду: " + Лев(Элемент.BORG, 4));
			Продолжить;
		КонецЕсли;
		
		Если Компании.Количество() = 0 Тогда
			Сообщить("Не удалось найти Parent company по коду: " + Элемент.ParentCompany + " и стране " + Элемент.Country);
			Продолжить;
		КонецЕсли;
		
		Для каждого ТекАУ из КостЦентры Цикл
			
			Для каждого ParentCompany Из Компании Цикл			
				СтрокаНабора = Набор.Добавить();
				СтрокаНабора.AU 			= ТекАУ;//Справочники.КостЦентры.НайтиПоКоду(Элемент.AU);
				СтрокаНабора.ParentCompany 	= ParentCompany;
				СтрокаНабора.BORG 			= BORG;
			КонецЦикла;
		
		КонецЦикла;
		
	КонецЦикла;
	
	ТаблицаНабора = Набор.Выгрузить();
	
	ТаблицаНабора.Свернуть("BORG, ParentCompany, AU", "");
	
	Набор.Загрузить(ТаблицаНабора);
	
	Если Набор.Количество() > 0 Тогда
		Набор.Записать();
	КонецЕсли;
КонецПроцедуры

Функция НайтиAUs(Номер)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	КостЦентры.Ссылка
	|ИЗ
	|	Справочник.КостЦентры КАК КостЦентры
	|ГДЕ
	|	КостЦентры.Код Подобно &Код
	|	И НЕ КостЦентры.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("Код", "%"+Номер);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ссылка");
	
КонецФункции

Функция НайтиКомпанию(Параметры)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	SoldTo.Ссылка
	|ИЗ
	|	Справочник.SoldTo КАК SoldTo
	|ГДЕ
	|	SoldTo.CompanyNo = &CompanyNo
	|	И SoldTo.Country.Код = &Country";
	
	Запрос.УстановитьПараметр("Country", Параметры.Country);
	Запрос.УстановитьПараметр("CompanyNo", Параметры.ParentCompany);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции