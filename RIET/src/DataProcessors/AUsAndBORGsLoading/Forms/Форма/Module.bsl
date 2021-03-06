
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
	
	ДиалогВыбораФайла.Фильтр						= "Файлы xls (*.xls)|*.xls|Файлы xlsx (*.xlsx)|*.xlsx";
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
				"Файл не выбран!",
				, "Объект", "FullPath");
				Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	 
	Состояние("Идет загрузка файла");
	
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьТаблицуAUИзФайлаXLS(FullPath);
	
	ЗагрузитьЗаписиAUsBORGs();
                                     	
КонецПроцедуры
                      
&НаКлиенте
Процедура ЗаполнитьТаблицуAUИзФайлаXLS(ПолноеИмяXLSФайла)
	
	Попытка
		Excel = Новый COMОбъект("Excel.Application");
	Исключение
		Сообщить("Не удалось открыть Excel: " + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Возврат;
	КонецПопытки;
	
	Попытка
		Excel.Workbooks.Open(FullPath);
	Исключение
		Excel.Quit();
		Сообщить("Не удалось открыть файл """ + ПолноеИмяXLSФайла + """ с помощью Excel: " + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Возврат;
	КонецПопытки;
		
	Попытка
		WorkSheet = Excel.Workbooks(1).Worksheets(1);
	Исключение
		Excel.Quit();
		Сообщить("Не удалось открыть лист файла """ + ПолноеИмяXLSФайла + """: " + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		Возврат;
	КонецПопытки;
	
	СвойстваСтруктуры = "AUCode, BorgCode";
    СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(WorkSheet, СвойстваСтруктуры);
	          	      		 
	//перебираем все заполненные строки файла 
	СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
	КоличествоЯчеек = СтруктураЗначенийСтроки.Количество();
	НомерСтроки = 2;
	Пока Истина Цикл
		
		//добавляем значение каждой ячейки файла в структуру значений
		Для Каждого ЭлементСтруктуры из СтруктураИменИНомеровКолонок Цикл 
			
			ЗначениеЯчейки = WorkSheet.Cells(НомерСтроки, ЭлементСтруктуры.Значение).Value;
			СтруктураЗначенийСтроки[ЭлементСтруктуры.Ключ] = ЗначениеЯчейки;
			
		КонецЦикла;
		
		//проверяем, если все ячейки пустые - считаем, что последняя строка
		КолВоНезаполненныхЭлементовСтруктуры = ВернутьКолВоНезаполненныхЭлементовСтруктуры(СтруктураЗначенийСтроки);
		Если КоличествоЯчеек = КолВоНезаполненныхЭлементовСтруктуры Тогда 
			Прервать;
		КонецЕсли;
		
		//добавляем строку Таблицы и пытаемся заполнить	
		Попытка
			
			НоваяСтрокаТаблицы = ТаблицаAUsBORGs.Добавить();
			Для Каждого ЭлементСтруктурыЗначений из СтруктураЗначенийСтроки Цикл 
				НоваяСтрокаТаблицы[ЭлементСтруктурыЗначений.Ключ] = ЭлементСтруктурыЗначений.Значение;	
			КонецЦикла;
			НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
			
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось загрузить данные в строке №" + НомерСтроки + " в колонке """ + ЭлементСтруктурыЗначений.Ключ + """!");
		КонецПопытки;
		
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;  
			
	Excel.Quit();
	
КонецПроцедуры

&НаКлиенте
Функция ВернутьКолВоНезаполненныхЭлементовСтруктуры(СтруктураЗначенийСтроки)
	
	КолВоНезаполненныхЯчеек = 0;
	Для Каждого КлючИЗначение Из СтруктураЗначенийСтроки Цикл
		
		Если КлючИЗначение.Значение = Неопределено Тогда
			КолВоНезаполненныхЯчеек = КолВоНезаполненныхЯчеек + 1;
		КонецЕсли; 
		
	КонецЦикла;
	
	Возврат КолВоНезаполненныхЯчеек;
	
КонецФункции
  
&НаКлиенте
Функция ПолучитьСтруктуруИменИНомеровКолонок(WorkSheet, СвойстваСтруктуры)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Пока Истина Цикл
		
		ТекстЯчейки = СокрЛП(WorkSheet.Cells(1, НомерКолонки).Text);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли; 
		
		Если НомерКолонки = 1 и ТекстЯчейки = "Borg code" Тогда
			СтруктураКолонокИИндексов.BorgCode = НомерКолонки;
		ИначеЕсли НомерКолонки = 2 и ТекстЯчейки = "AU code" Тогда
			СтруктураКолонокИИндексов.AUCode = НомерКолонки;
	   	КонецЕсли; 
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла; 
	
	Возврат СтруктураКолонокИИндексов;
	
КонецФункции

&НаСервере
Процедура ЗагрузитьЗаписиAUsBORGs() 
	                  		     	
	ПакетДанныхAUsBORGs = ПолучитьДанныеДляЗаполненияAUsBORGs();
	ТЗAUs   = ПакетДанныхAUsBORGs[0].Выгрузить();
	ТЗBORGs = ПакетДанныхAUsBORGs[1].Выгрузить();
	
	НоваяЗапись = РегистрыСведений.AUsAndBORGs.СоздатьМенеджерЗаписи();
	
	Для Каждого Стр из ТаблицаAUsBORGs Цикл 
		
		Отказ = Ложь;
		
		СтрокаAU = ТЗAUs.Найти(Стр.AUCode, "AUКод");
		Если СтрокаAU = Неопределено Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось найти Accounting unit по коду """ + СокрЛП(Стр.AUCode) + """!",
				,,, Отказ);
		КонецЕсли;
		
		СтрокаBORG = ТЗBORGs.Найти(Стр.BorgCode, "BorgКод");
		Если СтрокаBORG = Неопределено Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось найти BORG по коду """ + СокрЛП(Стр.BorgCode) + """!",
				,,, Отказ);
		КонецЕсли;
		
		Если Отказ Тогда
			Продолжить;
		КонецЕсли; 
		
		НоваяЗапись.AU   = СтрокаAU.AU;
		НоваяЗапись.BORG = СтрокаBORG.BORG;
		
		НоваяЗапись.Прочитать();
		Если НоваяЗапись.Выбран() Тогда 
			Продолжить;
		КонецЕсли;
		
		НоваяЗапись.AU   = СтрокаAU.AU;
		НоваяЗапись.BORG = СтрокаBORG.BORG;
		
		Попытка	
			НоваяЗапись.Записать();							
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось добавить запись в строке с ""AU " + СокрЛП(НоваяЗапись.AU) + """ ""BORG " + СокрЛП(НоваяЗапись.BORG) + """: "+ ОписаниеОшибки());
		КонецПопытки;   
		
	КонецЦикла;
	 			
КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеДляЗаполненияAUsBORGs()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивBorgCode", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(
																	                        ТаблицаAUsBORGs,"BorgCode"));
	Запрос.УстановитьПараметр("МассивAUCode", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(
																	                        ТаблицаAUsBORGs,"AUCode"));
	Запрос.Текст =
	    //-> RG-Soft VIvanov 2015/02/18
		//"ВЫБРАТЬ
		//|	КостЦентры.Ссылка КАК AU,
		//|	КостЦентры.Код КАК AUКод
		//|ИЗ
		//|	Справочник.КостЦентры КАК КостЦентры
		//|ГДЕ
		//|	(НЕ КостЦентры.ПометкаУдаления)
		//|	И КостЦентры.Код В(&МассивAUCode)
		"ВЫБРАТЬ
		|	СегментыКостЦентровСрезПоследних.КостЦентр КАК AU,
		|	СегментыКостЦентровСрезПоследних.Код КАК AUКод
		|ИЗ
		|	РегистрСведений.СегментыКостЦентров.СрезПоследних(&Дата, Код В (&МассивAUCode)) КАК СегментыКостЦентровСрезПоследних
		|ГДЕ
		|	НЕ СегментыКостЦентровСрезПоследних.КостЦентр.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	BORGs.Ссылка КАК BORG,
		|	BORGs.Код КАК BORGКод
		|ИЗ
		|	Справочник.BORGs КАК BORGs
		|ГДЕ
		|	НЕ BORGs.ПометкаУдаления
		|	И BORGs.Код В(&МассивBorgCode)";
	        		
	Запрос.УстановитьПараметр("Дата", ТекущаяДата());
	//<-
	Возврат Запрос.ВыполнитьПакет();
		
КонецФункции

