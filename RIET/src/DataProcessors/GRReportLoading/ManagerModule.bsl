
//Производит загрузку GR report из excel-файла с hub'a 

//регламентное задание
Процедура UploadGRReportFromHub() Экспорт
	
	//http://www.hub.slb.com/display/index.do?id=id3454385
	//http://www.hub.slb.com/Docs/sl/it_swps/SWPS/MasterData/GR_12_2014.zipx
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	GRReportsLoadingProcess.GRReportName КАК GRReportName,
	               |	GRReportsLoadingProcess.Период
	               |ИЗ
	               |	РегистрСведений.GRReportsLoadingProcess КАК GRReportsLoadingProcess
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	GRReportsLoadingProcess.Период УБЫВ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		ИмяGRReport = СокрЛП(Выборка.GRReportName);
	иначе
		РГСофт.СообщитьИЗалоггировать(
			"Нет ни одной записи GR report в регистре сведений GRReportsLoading",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено);
		Возврат;
	КонецЕсли;
	
	Попытка
		
		ПолучитьФайлGRReport(ИмяGRReport);
		
		//обновим запись
		МенеджерЗаписи = РегистрыСведений.GRReportsLoadingProcess.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Период = Выборка.Период;
		МенеджерЗаписи.GRReportName = ИмяGRReport;
		МенеджерЗаписи.UploadDate = ТекущаяДата(); 
		МенеджерЗаписи.Записать();
		
	Исключение
	КонецПопытки;
	
	//проверим есть ли более новый файл
	МесяцОтчета = Число(Сред(ИмяGRReport, 4, 2));
	ГодОтчета = Число(Сред(ИмяGRReport, 7, 4));
	
	Если МесяцОтчета = 12 Тогда
		МесяцОтчета = 1;
		ГодОтчета = ГодОтчета + 1;
	иначе
		МесяцОтчета = МесяцОтчета + 1;
	КонецЕсли;
	
	МесяцОтчетаСтрокой = ?(СтрДлина(СокрЛП(МесяцОтчета)) = 1, "0" + СокрЛП(МесяцОтчета), СокрЛП(МесяцОтчета));
	ГодОтчетаСтрокой = СтрЗаменить(СокрЛП(ГодОтчета), Символы.НПП, "");
	
	ИмяНовогоGRReport = "GR_" + МесяцОтчетаСтрокой + "_" + ГодОтчетаСтрокой;
	
	Попытка
		
	 	ПолучитьФайлGRReport(ИмяНовогоGRReport);
		
		//добавим новую запись
		МенеджерЗаписи = РегистрыСведений.GRReportsLoadingProcess.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Период = Дата(ГодОтчетаСтрокой, МесяцОтчетаСтрокой, 01);
		МенеджерЗаписи.GRReportName = ИмяНовогоGRReport;
		МенеджерЗаписи.UploadDate = ТекущаяДата(); 
		МенеджерЗаписи.Записать();
		
	Исключение
	КонецПопытки; 	
	       	
КонецПроцедуры 

Процедура ПолучитьФайлGRReport(ИмяGRReport)
	
	//получим файл 
	СерверИсточник = "www.hub.slb.com";
	СтрокаПараметраПолучения = "Docs/sl/it_swps/SWPS/MasterData/" + ИмяGRReport + ".zipx";
	ОбработкаПолученияФайлов = Обработки.ПолучениеФайловИзИнтернета.Создать();
                   	
	ВремКаталог = КаталогВременныхФайлов() + "tempGRReports";
	СоздатьКаталог(ВремКаталог);
	УдалитьФайлы(ВремКаталог, "*.*");
	ИмяВходящегоФайла = "" + ВремКаталог + "\" + "GRReport.zipx";
			
	Если ЗапроситьФайлыССервера(СерверИсточник, СтрокаПараметраПолучения, ИмяВходящегоФайла) <> Истина Тогда
		РГСофт.СообщитьИЗалоггировать(
			"Не удалось скачать файл GR report: " + ИмяGRReport + ".zipx",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено);
		УдалитьФайлы(ВремКаталог,"*.*");
		ВызватьИсключение "";
	КонецЕсли; 
         	
	//разархивируем файл
	Попытка
		ZipЧтение = Новый ЧтениеZipФайла(ИмяВходящегоФайла);
		ЭлементZipФайла = ZipЧтение.Элементы[0];
	Исключение
		РГСофт.СообщитьИЗалоггировать("Не удалось разархивировать GR report: " + ИмяGRReport + ".zipx",
			"Не удалось скачать файл GR report: " + ИмяGRReport + ".zipx",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено,
			ОписаниеОшибки());
		УдалитьФайлы(ВремКаталог,"*.*");
		ВызватьИсключение "";
	КонецПопытки;
	
	Если СтрНайти(ЭлементZipФайла.Имя, "xlsx") = 0 
		И СтрНайти(ЭлементZipФайла.Имя, "xls") = 0
		И СтрНайти(ЭлементZipФайла.Имя, "xlsb") = 0 Тогда
		РГСофт.СообщитьИЗалоггировать("ZIP-файл GR report не содержит excel-file",
			"Не удалось найти excel-файл в GR report: " + ИмяGRReport + ".zipx",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено);
		УдалитьФайлы(ВремКаталог,"*.*");
		ВызватьИсключение "";
	КонецЕсли;
		
	//ZipЧтение.Извлечь(ЭлементZipФайла, ВремКаталог, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	
	ПрограммаАрхивации = "C:\Program Files\7-Zip\7z.exe";
	Попытка
		ЗапуститьПриложение(ПрограммаАрхивации + " e " + ИмяВходящегоФайла + " -y -o" + ВремКаталог, ,Истина);
	Исключение
		РГСофт.СообщитьИЗалоггировать(
			"Не удалось распаковать файл GR report: " + ИмяGRReport + ".zipx",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено,
			ОписаниеОшибки());
		ВызватьИсключение ""
	КонецПопытки;
	
	ПолноеИмяФайла = ВремКаталог + "\" + ЭлементZipФайла.Имя;
	     		
	//загрузим файл
	Попытка
		ЗагрузитьДанныеИзФайла(ПолноеИмяФайла);
	Исключение
		РГСофт.СообщитьИЗалоггировать(
			"Не удалось загрузить файл GR report: " + ИмяGRReport + ".zipx",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено,
			ОписаниеОшибки());
		ВызватьИсключение ""
	КонецПопытки;

	УдалитьФайлы(ВремКаталог,"*.*");
	
КонецПроцедуры

// Функция получает файлы с сервера с указанными параметрами и сохраняет на диск
//
// Параметры:
//  HTTP - HTTPСоединение, если приходится использовать данную функцию в цикле, то тут передается
//         переменная с созданным в предыдущей итерации цикла HTTPСоединением
// СерверИсточникПараметр - Строка, сервер, с которого необходимо получить файлы
// СтрокаПараметраПолученияПараметр - Строка, адрес ресурса на сервере.
// ИмяВходящегоФайлаПараметр - Имя файла, в который помещаются данные полученного ресурса.
//
// Возвращаемое значение:
//  Булево - Успешно получены файлы или нет.
//
Функция ЗапроситьФайлыССервера(СерверИсточникПараметр, СтрокаПараметраПолученияПараметр, ИмяВходящегоФайлаПараметр, HTTP = Неопределено)

	СерверИсточник           = СерверИсточникПараметр;
	СтрокаПараметраПолучения = СтрокаПараметраПолученияПараметр;
	ИмяВходящегоФайла        = ИмяВходящегоФайлаПараметр;
	
	Если ТипЗнч(HTTP) <> Тип("HTTPСоединение") Тогда
		HTTP = Новый HTTPСоединение(СерверИсточник)
	КонецЕсли; 
	
	Попытка
		HTTP.Получить(СтрокаПараметраПолучения, ИмяВходящегоФайла);
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции


//////////////////////////////////////////////////////////////
// Загрузка доп. полей PO lines из Excel-файла 

Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла) Экспорт 
	
	ТекстОшибок = "";
	
	МассивСтруктурPOLines = ПолучитьМассивСтруктурPOLinesИзФайла(ТекстОшибок, ПолноеИмяФайла);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ДозаполнитьPO(ТекстОшибок, МассивСтруктурPOLines);
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекстОшибок) Тогда 
		РГСофт.СообщитьИЗалоггировать(
			"В ходе загрузки GR report из файла возникли ошибки!",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.GRReportLoading,
			Неопределено,
			ТекстОшибок + ОписаниеОшибки());
	КонецЕсли;
		
КонецПроцедуры

Функция ПолучитьМассивСтруктурPOLinesИзФайла(ТекстОшибок, ПолноеИмяФайла)
	
	МассивCOUNTRYCODE = ПолучитьМассивCOUNTRYCODE();
	
	МассивСтруктурPOLines = Новый Массив;
		
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
	
	ЛистЭксель = rs.Fields("TABLE_NAME").Value;
	
	sqlString = "select * from [" + ЛистЭксель + "]";
	rs.Close();
	rs.Open(sqlString);
	
	rs.MoveFirst();
	   	 	
	СвойстваСтруктуры = "PONUMBER,LINENUMBER,GRCREATEDATE,COUNTRYCODE,ORDEREDQTY,RECEIVEDQTY";
	СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
	
	НомерСтроки = 1;
	Пока rs.EOF = 0 Цикл
		
		НомерСтроки = НомерСтроки + 1;
						
		Если НомерСтроки = 2 Тогда 
			
			СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТекстОшибок);
			
			Если Не СтруктураИменИНомеровКолонок.свойство("COUNTRYCODE") Тогда
				СвойстваСтруктуры = "PONUMBER,LINENUMBER,GRCREATEDATE,ORDEREDQTY,RECEIVEDQTY";
				СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
			КонецЕсли;
			
			Если Не ПустаяСтрока(ТекстОшибок) Тогда 
				Прервать;
			КонецЕсли;
			
			rs.MoveNext();
			Продолжить;
			
		КонецЕсли;
		
		//добавляем значение каждой ячейки файла в структуру значений
		Для Каждого ЭлементСтруктуры из СтруктураИменИНомеровКолонок Цикл 
			
			ЗначениеЯчейки = rs.Fields(ЭлементСтруктуры.Значение-1).Value;
			СтруктураЗначенийСтроки[ЭлементСтруктуры.Ключ] = ЗначениеЯчейки;
			
		КонецЦикла;
		
		Если СтруктураИменИНомеровКолонок.свойство("COUNTRYCODE")
			И МассивCOUNTRYCODE.Найти(ВРЕГ(СокрЛП(СтруктураЗначенийСтроки.COUNTRYCODE))) = Неопределено Тогда
			rs.MoveNext();
			Продолжить;
		КонецЕсли;
		     
		
		//добавляем новую структуру и пытаемся заполнить	
		Попытка
			
			СтруктураPOLine = Новый Структура(СвойстваСтруктуры);
			
			Для Каждого ЭлементСтруктурыЗначений из СтруктураЗначенийСтроки Цикл 
				СтруктураPOLine[ЭлементСтруктурыЗначений.Ключ] = ЭлементСтруктурыЗначений.Значение;	
			КонецЦикла;
			
			СтруктураPOLine.Вставить("НомерСтрокиФайла", НомерСтроки);
			
			МассивСтруктурPOLines.Добавить(СтруктураPOLine);
			
		Исключение
			ТекстОшибок = ТекстОшибок + "
			|не удалось загрузить данные в строке №" + НомерСтроки + " в колонке '" + ЭлементСтруктурыЗначений.Ключ + "'!";
		КонецПопытки;
		
		rs.MoveNext();
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
	Возврат МассивСтруктурPOLines;
	
КонецФункции

Функция ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТекстОшибок)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Для Каждого Field из rs.Fields Цикл 
		
		ТекстЯчейки = ВРег(СокрЛП(Field.Value));
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли; 
		     
		Если ТекстЯчейки = "PONUMBER" Тогда
			СтруктураКолонокИИндексов.PONUMBER = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "LINENUMBER" Тогда
			СтруктураКолонокИИндексов.LINENUMBER = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "GRCREATEDATE" Тогда
			СтруктураКолонокИИндексов.GRCREATEDATE = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "COUNTRYCODE" Тогда
			СтруктураКолонокИИндексов.COUNTRYCODE = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ORDEREDQTY" Тогда
			СтруктураКолонокИИндексов.ORDEREDQTY = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "RECEIVEDQTY" Тогда
			СтруктураКолонокИИндексов.RECEIVEDQTY = НомерКолонки;
		КонецЕсли;   
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла; 
	
	Для Каждого КлючИЗначение Из СтруктураКолонокИИндексов Цикл
		
		Если КлючИЗначение.Значение = Неопределено Тогда
			
			Если КлючИЗначение.Ключ = "COUNTRYCODE" Тогда
				
				СтруктураКолонокИИндексов.Удалить("COUNTRYCODE");
				
			Иначе 
				
				ТекстОшибок = ТекстОшибок + "
				|необходимо проверить наличие колонки с данными '" + КлючИЗначение.Ключ + "'!";
				
			КонецЕсли;
		
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтруктураКолонокИИндексов;
	
КонецФункции

Процедура ДозаполнитьPO(ТекстОшибок, МассивСтруктурPOLines) 
	                  		     	
	ТЗДанныхPOLines = ПолучитьДанныеДляЗаполненияPOLines(МассивСтруктурPOLines);
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(ТЗДанныхPOLines, "POCode");
	
	СтруктураОтбора = Новый Структура("POCode,POLineNumber");
	
	Для Каждого СтруктураPOLine из МассивСтруктурPOLines Цикл 
		
		СтруктураОтбора.POCode = СтруктураPOLine.PONUMBER;
		СтруктураОтбора.POLineNumber = Число(СтруктураPOLine.LINENUMBER);
		
		МассивСтрокДанныхPOLine = ТЗДанныхPOLines.НайтиСтроки(СтруктураОтбора);
		
		Если МассивСтрокДанныхPOLine.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Для Каждого СтрокаДанныхPOLine из МассивСтрокДанныхPOLine Цикл 
			
			POLineОбъект = СтрокаДанныхPOLine.POLine.ПолучитьОбъект();
			
			//ORDEREDQTY vs RECEIVEDQTY - очищаем дату			
			Если СтруктураPOLine.ORDEREDQTY <> СтруктураPOLine.RECEIVEDQTY Тогда
				
				РГСофтКлиентСервер.УстановитьЗначение(POLineОбъект.GoodsReceiptDate, Дата(1,1,1));
				
			иначе
				
				Если ПустаяСтрока(СтруктураPOLine.GRCREATEDATE) Тогда 
					Продолжить;
				КонецЕсли;
				
				GoodsReceiptDate = ПолучитьДатуИзСтроки(СтруктураPOLine.GRCREATEDATE);
				
				Если GoodsReceiptDate = Неопределено Тогда 
					ТекстОшибок = ТекстОшибок + "
					|не удалось конвертировать дату '" + СокрЛП(СтруктураPOLine.GRCREATEDATE) + "'";                                    
					Продолжить;	
				КонецЕсли;
				
				РГСофтКлиентСервер.УстановитьЗначение(POLineОбъект.GoodsReceiptDate, GoodsReceiptDate);
				
			КонецЕсли;
		
			Если POLineОбъект.Модифицированность() Тогда 
				
				POLineОбъект.ОбменДанными.Загрузка = Истина;
				Попытка 
					POLineОбъект.Записать();
				Исключение
					ТекстОшибок = ТекстОшибок + "
					|не удалось записать PO line '" + СокрЛП(POLineОбъект) + "' 
					|"+ ОписаниеОшибки();                                    
				КонецПопытки;   
				
			КонецЕсли;
			
		КонецЦикла; 
		
	КонецЦикла; 	
		
КонецПроцедуры

Функция ПолучитьДанныеДляЗаполненияPOLines(МассивСтруктурPOLines)
	
	Запрос = Новый Запрос;
	
	МассивКодов = Новый Массив;
	Для Каждого СтруктураPOLine из МассивСтруктурPOLines Цикл 
		МассивКодов.Добавить(СтруктураPOLine.PONUMBER);
	КонецЦикла; 
	
    Запрос.УстановитьПараметр("МассивКодов", МассивКодов);

	Запрос.Текст = "ВЫБРАТЬ
	               |	СтрокиЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку КАК POLineNumber,
	               |	СтрокиЗаявкиНаЗакупку.Владелец.Код КАК POCode,
	               |	СтрокиЗаявкиНаЗакупку.Ссылка КАК POLine,
	               |	СтрокиЗаявкиНаЗакупку.GoodsReceiptDate
	               |ИЗ
	               |	Справочник.СтрокиЗаявкиНаЗакупку КАК СтрокиЗаявкиНаЗакупку
	               |ГДЕ
	               |	НЕ СтрокиЗаявкиНаЗакупку.ПометкаУдаления
	               |	И СтрокиЗаявкиНаЗакупку.Владелец.Код В(&МассивКодов)";
	        		
	Возврат Запрос.Выполнить().Выгрузить();
		
КонецФункции

Функция ПолучитьДатуИзСтроки(Знач ДатаСтрока) 
	   	
	ДатаСтрока = СокрЛП(ДатаСтрока);
	
	ПозицияРазделителя = СтрНайти(ДатаСтрока, "/");
	Если ПозицияРазделителя = 0 Тогда 
		ПозицияРазделителя = СтрНайти(ДатаСтрока, ".");
	КонецЕсли;
	
	ДеньСтрока = Лев(ДатаСтрока, ПозицияРазделителя-1);
	Попытка
		День = Число(СокрЛП(ДеньСтрока));
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	ДатаСтрока = Сред(ДатаСтрока, ПозицияРазделителя+1);

	ПозицияРазделителя = СтрНайти(ДатаСтрока, "/");
	Если ПозицияРазделителя = 0 Тогда 
		ПозицияРазделителя = СтрНайти(ДатаСтрока, ".");
	КонецЕсли;
	
	МесяцСтрока = Лев(ДатаСтрока, ПозицияРазделителя-1);
	Попытка
		Месяц = Число(СокрЛП(МесяцСтрока));
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	ГодСтрока = Прав(ДатаСтрока, 4);	
	Попытка
		Год = Число(ГодСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Попытка
		ИтоговаяДата = Дата(Год, Месяц, День);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат ИтоговаяДата;
			
КонецФункции

Функция ПолучитьМассивCOUNTRYCODE()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	CountriesOfProcessLevels.Код КАК Code
	|ИЗ
	|	Справочник.CountriesOfProcessLevels КАК CountriesOfProcessLevels";
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(ТЗ, "Code");
	
	Возврат ТЗ.ВыгрузитьКолонку("Code"); 	
	
КонецФункции

