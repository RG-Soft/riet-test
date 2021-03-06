
&НаКлиенте
Процедура LoadFromExcel(Команда)
	
	ТекстВопроса = "Load projects from excel?";
	Ответ = Вопрос(ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
	Если Ответ = КодВозвратаДиалога.Да Тогда
		
		НастройкиДиалога = Новый Структура;
		НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsx (*.xlsx)'") + "|*.xlsx" );
		НастройкиДиалога.Вставить("Projects", ЭтотОбъект);
		
		Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект);
		ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
		
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ШаблонExcel(Команда)
	
	Адрес = ШаблонExcelНаСервере();
	Если Адрес <> Неопределено Тогда
		ИмяФайла = "Project_loading_template.xlsx";
		ПолучитьФайл(Адрес, ИмяФайла);
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура LoadFile(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	АдресФайла = РезультатПомещенияФайлов.Хранение;
	РасширениеФайла = "xlsx";
	ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, Projects)
	
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);

	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);

	ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла, Projects);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла, Projects)  
	
	ТекстОшибок = "";
	
	ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, Projects);
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибок);
	КонецЕсли;
			
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
		
		СвойстваСтруктуры = "Name,StartDate,EndDate,ProjectClient,LawsonProjectClientCode,ProjectOwner,Geomarket";
		
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
		
		Если ТекстЯчейки = "Name" Тогда
			СтруктураКолонокИИндексов.Name = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "StartDate" Тогда
			СтруктураКолонокИИндексов.StartDate = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "EndDate" Тогда
			СтруктураКолонокИИндексов.EndDate = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ProjectClient" Тогда
			СтруктураКолонокИИндексов.ProjectClient = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "LawsonProjectClientCode" Тогда
			СтруктураКолонокИИндексов.LawsonProjectClientCode = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ProjectOwner" Тогда
			СтруктураКолонокИИндексов.ProjectOwner = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Geomarket" Тогда
			СтруктураКолонокИИндексов.Geomarket = НомерКолонки;
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
Процедура ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, Projects)
	
	СформироватьПоДаннымExcel(ТаблицаExcel, Projects);
	
КонецПроцедуры

&НаСервере
Процедура СформироватьПоДаннымExcel(ТаблицаExcel, Projects)
	
	НачатьТранзакцию();
	i = 0;
	Для Каждого Элемент Из ТаблицаExcel Цикл
		
		Geomarket = Справочники.GeoMarkets.НайтиПоКоду(СокрЛП(Элемент.Geomarket));
		Если НЕ ЗначениеЗаполнено(Geomarket) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось определить 'Geomarket' - " + СокрЛП(Элемент.Geomarket) + " в строке файла №" + СокрЛП(Элемент.НомерСтрокиФайла),
			, , , );
		КонецЕсли;
		ProjectClient = Справочники.КонтрагентыLawson.НайтиПоКоду(СокрЛП(Элемент.LawsonProjectClientCode));
		Если НЕ ЗначениеЗаполнено(ProjectClient) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось определить 'Project client' - " + СокрЛП(Элемент.ProjectClient) + " в строке файла №" + СокрЛП(Элемент.НомерСтрокиФайла),
			, , , );
		КонецЕсли;
		ProjectOwner = Справочники.Пользователи.НайтиПоНаименованию(СокрЛП(Элемент.ProjectOwner));
		Если НЕ ЗначениеЗаполнено(ProjectOwner) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось определить 'Project owner' - " + СокрЛП(Элемент.ProjectOwner) + " в строке файла №" + СокрЛП(Элемент.НомерСтрокиФайла),
			, , , );
		КонецЕсли;
		
		Project = Справочники.ProjectMobilization.СоздатьЭлемент();
		Project.StartDate = Дата(СокрЛП(Элемент.StartDate) + " 00:00:00");
		Project.EndDate = Дата(СокрЛП(Элемент.EndDate) + " 00:00:00");
		Project.ProjectOwner = ProjectOwner;
		Project.Geomarket = Geomarket;
		Project.ProjectClient = ProjectClient;
		Project.Наименование = СокрЛП(Элемент.Name);
		
		Попытка
			Если ЗначениеЗаполнено(Project.ProjectOwner) И ЗначениеЗаполнено(Project.Geomarket) И ЗначениеЗаполнено(Project.ProjectClient) И 
					ЗначениеЗаполнено(Project.Наименование) И ЗначениеЗаполнено(Project.StartDate) И ЗначениеЗаполнено(Project.EndDate) Тогда
				Project.Записать();
				i = i + 1;
			КонецЕсли;
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось определить записать проект из строки файла №" + СокрЛП(Элемент.НомерСтрокиФайла),
			, , , );
		КонецПопытки;
		
	КонецЦикла;
	ЗафиксироватьТранзакцию();
	
	Сообщить("Успешно загружено элементов - " + i, СтатусСообщения.Информация);
	
КонецПроцедуры

&НаСервере
Функция ШаблонExcelНаСервере()
	
	ТабДок = Новый ТабличныйДокумент;
	Макет = Справочники.ProjectMobilization.ПолучитьМакет("ExcelШаблонДляЗагрузки");
	Шаблон = Макет.ПолучитьОбласть("ШаблонЗагрузки");
	
	ТабДок.Вывести(Шаблон);
	Имя = ПолучитьИмяВременногоФайла(".xlsx");
	ТабДок.Записать(Имя, ТипФайлаТабличногоДокумента.XLSX);
	Двоичное = Новый ДвоичныеДанные(Имя);
	Адрес = ПоместитьВоВременноеХранилище(Двоичное);
	Попытка
		УдалитьФайлы(Имя);
	Исключение
	КонецПопытки;
	Возврат Адрес
	
КонецФункции
