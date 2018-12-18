
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
	
	ДиалогВыбораФайла.Фильтр						= "Файлы csv|*.csv";
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
		
	КонецЕсли;
	 
	ЗагрузитьPOИзФайла(FullPath);		
		
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьPOИзФайла(ПолноеИмяФайла) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ПолноеИмяФайла) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Please, select a file!",
			, "Объект", "FullPath");
			Возврат;		
	КонецЕсли;
	
	// Прочитаем файл в текстовый документ
	Состояние("Reading file...");
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ТолькоПросмотр = Истина;	
	Попытка
		ТекстовыйДокумент.Прочитать(ПолноеИмяФайла);
	Исключение
		Сообщить("Failed to read file!
			|" + ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	
	// Разберем прочитанный текст
	Состояние("Parsing file...");
	Попытка
		РазобратьТекстовыйДокумент(ТекстовыйДокумент);
	Исключение
		Сообщить("Failed to parse file!
			|" + ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	
	Объект.КешAUs.Очистить();
	Объект.КешBORGs.Очистить();	
	Объект.ДанныеPOs.Сортировать("Код");
	
	Состояние("Creating POs and PO lines...");
	
	Попытка
		СоздатьОбъектыБазы();
		ПоказатьОповещениеПользователя(, , "POs were successfully loaded");
	Исключение
		Сообщить(ОписаниеОшибки());
		Предупреждение(
			"There were errors!
			|No PO was loaded!",
			60,
			"Attention!");
		Возврат;
	КонецПопытки;

	Попытка
		ПереместитьФайлВПапкуDone(ПолноеИмяФайла);
	Исключение
		Сообщить(
			"Failed to move file to directory Done!
			|" + ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// РАЗБОР ФАЙЛА

&НаКлиенте
Функция РазобратьТекстовыйДокумент(ТекстовыйДокумент)
	
	НомерТекущейСтроки = 12;
	Разделитель = """,""";
	
	Объект.ДанныеPOs.Очистить();
	Объект.ДанныеPOLines.Очистить();
		
	Состояние("Determining the structure of the file...");
	СтрокаЗаголовков = ТекстовыйДокумент.ПолучитьСтроку(НомерТекущейСтроки);
	МассивЗаголовков = РазложитьСтрокуВМассив(СтрокаЗаголовков, Разделитель);	
	СоответствиеКолонокИИндексов = ПолучитьСоответствиеКолонокИИндексов(МассивЗаголовков);
	
	КоличествоСтрок = ТекстовыйДокумент.КоличествоСтрок();
	КоличествоСтолбцов = МассивЗаголовков.Количество();	
	ПредыдущийМассивДанных = Неопределено;
	СтруктураПоискаPO = Новый Структура("Код");
	КоэффициентИндикатора = 100 / (КоличествоСтрок * 2);
	
	ВремяНачала = ТекущаяДата();
	Для НомерТекущейСтроки = НомерТекущейСтроки + 1 По КоличествоСтрок Цикл
		
		Если ТекущаяДата() - ВремяНачала > 2 Тогда
			Процент = Окр(НомерТекущейСтроки * КоэффициентИндикатора, 2);
			Состояние("Разобрано " + (НомерТекущейСтроки-1) + " строк из " + КоличествоСтрок + " (" + Процент + "%)", Процент);
			ВремяНачала = ТекущаяДата();
		КонецЕсли;
		ОбработкаПрерыванияПользователя();
		
		ПрефиксТекстаОшибки = "Строка №" + НомерТекущейСтроки + ": ";
			
		СтрокаДанных = ТекстовыйДокумент.ПолучитьСтроку(НомерТекущейСтроки);
		МассивДанных = РазложитьСтрокуВМассив(СтрокаДанных, Разделитель);
		
		// Бывает так, что в каком-нибудь поле закрадывается перенос строки
		// В этом случае надо искать продолжение ячеек на следующей строке
		Если ПредыдущийМассивДанных <> Неопределено Тогда
			
			ИндексПоследнейЯчейки = ПредыдущийМассивДанных.ВГраница();
			Если МассивДанных.Количество() Тогда
				
				ПредыдущийМассивДанных[ИндексПоследнейЯчейки] = ПредыдущийМассивДанных[ИндексПоследнейЯчейки] + МассивДанных[0];
				МассивДанных.Удалить(0);
				Для Каждого ЯчейкаДанных Из МассивДанных Цикл
					ПредыдущийМассивДанных.Добавить(ЯчейкаДанных);
				КонецЦикла;
				
			КонецЕсли;
			
			МассивДанных = ПредыдущийМассивДанных;
			
		КонецЕсли;
		
		ТекущееКоличествоЯчеек = МассивДанных.Количество();
		Если ТекущееКоличествоЯчеек < КоличествоСтолбцов Тогда	
			
			ПредыдущийМассивДанных = МассивДанных;
			Продолжить;
						
		КонецЕсли;
		
		ПредыдущийМассивДанных = Неопределено;
		
		// PO
		
		СтруктураПоискаPO.Код = МассивДанных[СоответствиеКолонокИИндексов.Получить("PO Num")];	
		Если Объект.ДанныеPOs.НайтиСтроки(СтруктураПоискаPO).Количество() = 0 Тогда
		
			НоваяСтрокаPO = Объект.ДанныеPOs.Добавить();
			
			НоваяСтрокаPO.Код =	СтруктураПоискаPO.Код;
			
			ИндексКолонкиБорга = СоответствиеКолонокИИндексов.Получить("Borg Name"); 
			КодБорга = МассивДанных[ИндексКолонкиБорга];
			КодБорга = Лев(КодБорга, 4);
			ПозицияТире = СтрНайти(КодБорга, "-");
			Если ПозицияТире > 0 Тогда
				КодБорга = Лев(КодБорга, ПозицияТире-1);
			КонецЕсли;
			НоваяСтрокаPO.КодБорга = КодБорга;
			
			НоваяСтрокаPO.СтранаПоставщика = МассивДанных[СоответствиеКолонокИИндексов.Получить("Supplier Country")];
			
			НоваяСтрокаPO.ТипПоставщика = МассивДанных[СоответствиеКолонокИИндексов.Получить("Supplier Type")];
			
			НоваяСтрокаPO.ДатаЗаявкиНаЗакупку = МассивДанных[СоответствиеКолонокИИндексов.Получить("PO Create Date")];
																
			НоваяСтрокаPO.Посредник = МассивДанных[СоответствиеКолонокИИндексов.Получить("ISUP")];
			
			НоваяСтрокаPO.Поставщик = МассивДанных[СоответствиеКолонокИИндексов.Получить("Supplier Name")]; 
				
			НоваяСтрокаPO.ИмяЗаказчика = МассивДанных[СоответствиеКолонокИИндексов.Получить("Purchaser name")];
			
			НоваяСтрокаPO.Податель = МассивДанных[СоответствиеКолонокИИндексов.Получить("Submitter Name")];
			
			НоваяСтрокаPO.Грузополучатель = МассивДанных[СоответствиеКолонокИИндексов.Получить("Shipto Label")];
			
			НоваяСтрокаPO.Комментарий = МассивДанных[СоответствиеКолонокИИндексов.Получить("ReqName")];
			
			НоваяСтрокаPO.ShoppingCartNo = МассивДанных[СоответствиеКолонокИИндексов.Получить("Req Num")];
			
			НоваяСтрокаPO.SubmitDate = МассивДанных[СоответствиеКолонокИИндексов.Получить("Submit Date")];
																
		КонецЕсли;
		
		НоваяСтрокаPOLine = Объект.ДанныеPOLines.Добавить();
		НоваяСтрокаPOLine.КодPO = СтруктураПоискаPO.Код;
		
		ИндексКолонкиНомераСтрокиPO = СоответствиеКолонокИИндексов.Получить("Line number");
		НомерСтрокиПОТекст = МассивДанных[ИндексКолонкиНомераСтрокиPO];
		НоваяСтрокаPOLine.НомерСтрокиЗаявкиНаЗакупку = Прав("000" + НомерСтрокиПОТекст, 3);
		
		НоваяСтрокаPOLine.КодЕдиницыИзмерения = МассивДанных[СоответствиеКолонокИИндексов.Получить("Unit Of Measure")];
		
		НоваяСтрокаPOLine.НаименованиеВалюты = МассивДанных[СоответствиеКолонокИИндексов.Получить("Currency")]; 
		
		НоваяСтрокаPOLine.КодAU = МассивДанных[СоответствиеКолонокИИндексов.Получить("ERP CC/AU")]; 					
		
		НоваяСтрокаPOLine.АктивитиКод = МассивДанных[СоответствиеКолонокИИндексов.Получить("IP Activity Code")];
		
		НоваяСтрокаPOLine.Классификатор = МассивДанных[СоответствиеКолонокИИндексов.Получить("ERP Accounting Treatment")];
		
		НоваяСтрокаPOLine.Количество = МассивДанных[СоответствиеКолонокИИндексов.Получить("Quantity")];
						
		НоваяСтрокаPOLine.Цена = МассивДанных[СоответствиеКолонокИИндексов.Получить("Unit Cost")];
						
		НоваяСтрокаPOLine.ИтогоПоСтроке = МассивДанных[СоответствиеКолонокИИндексов.Получить("Extended Cost")];
						
		НоваяСтрокаPOLine.ИтогоПоСтрокеДолл = МассивДанных[СоответствиеКолонокИИндексов.Получить("Extended Cost (USD)")];
	
		НоваяСтрокаPOLine.НазначениеРасходов = МассивДанных[СоответствиеКолонокИИндексов.Получить("Commodity")];
		
		НоваяСтрокаPOLine.ТипНазначенияРасходов = МассивДанных[СоответствиеКолонокИИндексов.Получить("Commodity Type")];
					
		НоваяСтрокаPOLine.ТипЗапроса = МассивДанных[СоответствиеКолонокИИндексов.Получить("Type of Requisition")];
					
		НоваяСтрокаPOLine.КодПоставщика = МассивДанных[СоответствиеКолонокИИндексов.Получить("Supplier Part Num")];
					
		ОписаниеНоменклатуры = МассивДанных[СоответствиеКолонокИИндексов.Получить("Part description")];		
		
		#Если Не ВебКлиент тогда
		Пока НайтиНедопустимыеСимволыXML(ОписаниеНоменклатуры) > 0 Цикл 
			
			ПозицияСимвола = НайтиНедопустимыеСимволыXML(ОписаниеНоменклатуры);
			НекорректныйСимвол = Сред(ОписаниеНоменклатуры, ПозицияСимвола, 1);
			ОписаниеНоменклатуры = СтрЗаменить(ОписаниеНоменклатуры, НекорректныйСимвол, "");
			
		КонецЦикла;
		#КонецЕсли
	
		НоваяСтрокаPOLine.ОписаниеНоменклатуры = ОписаниеНоменклатуры;
		
		НоваяСтрокаPOLine.СпособПеревозки = МассивДанных[СоответствиеКолонокИИндексов.Получить("Ship Method")];
		
		НоваяСтрокаPOLine.ИнструкцииПоТранспортировке = МассивДанных[СоответствиеКолонокИИндексов.Получить("Shipping Instructions")];
		
		НоваяСтрокаPOLine.СпециальныеИнструкции = МассивДанных[СоответствиеКолонокИИндексов.Получить("Special Instructions")];
						
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Функция РазложитьСтрокуВМассив(Строка, Разделитель)
	
	Массив = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Строка, Разделитель);
	
	ы = 0;
	ВГраница = Массив.ВГраница();
	Пока ы <= ВГраница Цикл
		Массив[ы] = СокрЛП(Массив[ы]);
		Массив[ы] = СтрЗаменить(Массив[ы], """", "");
		ы = ы + 1;
	КонецЦикла;
	
    Возврат Массив;
	
КонецФункции

&НаКлиенте
Функция ПолучитьСоответствиеКолонокИИндексов(МассивЗаголовков)
	
	СоответствиеКолонокИИндексов = Новый Соответствие;
	СоответствиеКолонокИИндексов.Вставить("Borg Name", 0);
	СоответствиеКолонокИИндексов.Вставить("Purchaser name", 0);
	СоответствиеКолонокИИндексов.Вставить("ReqName", 0);
	СоответствиеКолонокИИндексов.Вставить("Submitter Name", 0);
	СоответствиеКолонокИИндексов.Вставить("PO Num", 0);
	СоответствиеКолонокИИндексов.Вставить("PO Create Date", 0);
	СоответствиеКолонокИИндексов.Вставить("ISUP", 0);
	СоответствиеКолонокИИндексов.Вставить("Supplier Name", 0);
	СоответствиеКолонокИИндексов.Вставить("Supplier Type", 0);
	СоответствиеКолонокИИндексов.Вставить("Supplier Country", 0);
	СоответствиеКолонокИИндексов.Вставить("Shipto Label", 0);
	СоответствиеКолонокИИндексов.Вставить("Line number", 0);
	СоответствиеКолонокИИндексов.Вставить("Commodity", 0);
	СоответствиеКолонокИИндексов.Вставить("Commodity Type", 0);
	СоответствиеКолонокИИндексов.Вставить("Type of Requisition", 0);
	СоответствиеКолонокИИндексов.Вставить("Supplier Part Num", 0);
	СоответствиеКолонокИИндексов.Вставить("Part description", 0);
	СоответствиеКолонокИИндексов.Вставить("Quantity", 0);
	СоответствиеКолонокИИндексов.Вставить("Unit Of Measure", 0);
	СоответствиеКолонокИИндексов.Вставить("Unit Cost", 0);
	СоответствиеКолонокИИндексов.Вставить("Currency", 0);
	СоответствиеКолонокИИндексов.Вставить("Extended Cost", 0);
	СоответствиеКолонокИИндексов.Вставить("Extended Cost (USD)", 0);
	СоответствиеКолонокИИндексов.Вставить("Ship Method", 0);
	СоответствиеКолонокИИндексов.Вставить("Shipping Instructions", 0);
	СоответствиеКолонокИИндексов.Вставить("Special Instructions", 0);
	СоответствиеКолонокИИндексов.Вставить("IP Activity Code", 0);
	СоответствиеКолонокИИндексов.Вставить("ERP Accounting Treatment", 0);
	СоответствиеКолонокИИндексов.Вставить("Cost center", 0);
	СоответствиеКолонокИИндексов.Вставить("ERP CC/AU", 0);
	СоответствиеКолонокИИндексов.Вставить("Submit Date", 0);
	СоответствиеКолонокИИндексов.Вставить("Req Num", 0);
	
	Для Каждого КлючИЗначение Из СоответствиеКолонокИИндексов Цикл
		
		ИндексКолонки = МассивЗаголовков.Найти(КлючИЗначение.Ключ);
		Если ИндексКолонки = Неопределено Тогда
			ВызватьИсключение "Failed to determine the position of the column """ + КлючИЗначение.Ключ + """!";
		Иначе
			СоответствиеКолонокИИндексов.Вставить(КлючИЗначение.Ключ, ИндексКолонки);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СоответствиеКолонокИИндексов;
	
КонецФункции


//////////////////////////////////////////////////////////////////////////////////////
// СОЗДАНИЕ ОБЪЕКТОВ БАЗЫ

// ДОДЕЛАТЬ
&НаСервере
Процедура СоздатьОбъектыБазы()
	
	Отказ = Ложь;
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	СтруктураПоискаПоКоду = Новый Структура("Код");
	СтруктураПоискаПоНаименованию = Новый Структура("Наименование");
	СтруктураПоискаПоНаименованиюENG = Новый Структура("НаименованиеENG");
	СтруктураПоискаPOLines = Новый Структура("КодPO");
	
	Если Объект.КешAUs.Количество() = 0 Тогда
		Объект.КешAUs.Загрузить(ПолучениеСсылок.ПолучитьТаблицуAU());
	КонецЕсли;
	
	Если Объект.КешBORGs.Количество() = 0 Тогда
		ЗаполнитьКешBORGs();
	КонецЕсли;
					
	Для Каждого СтрокаPO Из Объект.ДанныеPOs Цикл
		
		// Получим значения реквизитов, необходимых как для PO, так и для PO Line
			
		// BORG
		НайденныйБорг = Неопределено;
		ЭтоLawsonКомпания = Истина;
		АльтернативныйAU = Неопределено;
		
		СтруктураПоискаПоКоду.Код = СтрокаPO.КодБорга;
		НайденныеBORGs = Объект.КешBORGs.НайтиСтроки(СтруктураПоискаПоКоду);	
		Если НайденныеBORGs.Количество() = 0 Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"PO """ + СтрокаPO.Код + """: failed to find BORG by code """ + СтруктураПоискаПоКоду.Код + """!",
				,,, Отказ);
					
		Иначе
			
			НайденныйБорг = НайденныеBORGs[0].Ссылка;
			ЭтоLawsonКомпания = НайденныеBORGs[0].Lawson;
			АльтернативныйAU = НайденныеBORGs[0].DefaultAU;
			АльтернативныйAC = НайденныеBORGs[0].DefaultAC;
			ЭтоOracleERP = НайденныеBORGs[0].OracleERP;
			
			Если (НЕ ЭтоLawsonКомпания ИЛИ ЭтоOracleERP)
				И НЕ ЗначениеЗаполнено(АльтернативныйAU) Тогда
			
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"PO """ + СтрокаPO.Код + """: default AU in BORG """ + НайденныйБорг + """ is empty!",
					,,, Отказ);
			
			КонецЕсли;
	
		КонецЕсли;
													
		ДатаЗаявкиНаЗакупку = ПреобразоватьСтрокуВДату(СтрокаPO.ДатаЗаявкиНаЗакупку);
		Если ДатаЗаявкиНаЗакупку = Неопределено Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"PO """ + СтрокаPO.Код + """: failed to convert """ + СтрокаPO.ДатаЗаявкиНаЗакупку + """ to PO date!",
				,,, Отказ);
		КонецЕсли;
		
		SubmitDate = ПреобразоватьСтрокуВДату(СтрокаPO.SubmitDate);
		Если SubmitDate = Неопределено Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"PO """ + СтрокаPO.Код + """: failed to convert """ + СтрокаPO.SubmitDate + """ to Submit date!",
				,,, Отказ);
		КонецЕсли;
			
		// PO
					
		Если Отказ Тогда
			
			// Если Отказ, значит транзакция будет отменена, значит не стоит тратить силы на поиски PO
			НайденнаяPO = Справочники.ЗаявкиНаЗакупку.ПустаяСсылка();
			
		Иначе
			
			// При загрузке PO не может происходить ошибок, так как не преобразовываются значения и не ищутся ссылки,
			//	поэтому для целей оптимизации обращение к ячейкам Excel происходит только если НЕ Отказ
			НайденнаяPO = Справочники.ЗаявкиНаЗакупку.НайтиПоКоду(СтрокаPO.Код);
			Если НайденнаяPO.Пустая() ИЛИ UpdateExistingPOs Тогда	
				
				Если НайденнаяPO.Пустая() Тогда 
					
					POОбъект = Справочники.ЗаявкиНаЗакупку.СоздатьЭлемент();
					POОбъект.Код = СтрокаPO.Код;
					POОбъект.Борг = НайденныйБорг;
					
				Иначе
					POОбъект = НайденнаяPO.ПолучитьОбъект();
				КонецЕсли; 
				
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.ДатаЗаявкиНаЗакупку, НачалоДня(ДатаЗаявкиНаЗакупку)); 
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.SubmitDate, НачалоДня(SubmitDate)); 
								
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.Посредник, СтрокаPO.Посредник);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.Поставщик, СтрокаPO.Поставщик); 
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.СтранаПоставщика, СтрокаPO.СтранаПоставщика);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.ТипПоставщика, СтрокаPO.ТипПоставщика);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.ИмяЗаказчика, СтрокаPO.ИмяЗаказчика);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.Податель, СтрокаPO.Податель);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.Грузополучатель, СтрокаPO.Грузополучатель);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.Комментарий, СтрокаPO.Комментарий);
				РГСофтКлиентСервер.УстановитьЗначение(POОбъект.ShoppingCartNo, СтрокаPO.ShoppingCartNo);
				
				Если POОбъект.Модифицированность() Тогда
					Попытка
						POОбъект.Записать();
						НайденнаяPO = POОбъект.Ссылка;
					Исключение
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
							"Failed to save PO """ + POОбъект + """:
								|" + ОписаниеОшибки(),
							,,, Отказ);
					КонецПопытки;
				КонецЕсли; 
				
			КонецЕсли;				
							
		КонецЕсли;
					
		// PO LINES

		СтруктураПоискаPOLines.КодPO = СтрокаPO.Код;
		СтрокиPOLines = Объект.ДанныеPOLines.НайтиСтроки(СтруктураПоискаPOLines);
		
		Для Каждого СтрокаPOLine Из СтрокиPOLines Цикл
		
			КодСтрокиPO = СтрокаPO.Код + "-" + СтрокаPOLine.НомерСтрокиЗаявкиНаЗакупку;
			НайденнаяСтрокаPO = Справочники.СтрокиЗаявкиНаЗакупку.НайтиПоКоду(КодСтрокиPO);
			Если НайденнаяСтрокаPO.Пустая() ИЛИ UpdateExistingPOs Тогда
				
				Если НайденнаяСтрокаPO.Пустая() Тогда
					СтрокаPOОбъект = Справочники.СтрокиЗаявкиНаЗакупку.СоздатьЭлемент();
					СтрокаPOОбъект.Владелец	= НайденнаяPO;
					СтрокаPOОбъект.Код = КодСтрокиPO;
				Иначе
					СтрокаPOОбъект = НайденнаяСтрокаPO.ПолучитьОбъект();
				КонецЕсли;
				
				// Обработаем поля, в которых может быть ошибка
				
				// Номер строки PO
				Попытка
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.НомерСтрокиЗаявкиНаЗакупку, Число(СтрокаPOLine.НомерСтрокиЗаявкиНаЗакупку));
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to convert """ + СтрокаPOLine.НомерСтрокиЗаявкиНаЗакупку + """ to PO line no.!",
						,,, Отказ);
				КонецПопытки;
				
				// Единица измерения
				UOM = CustomsСерверПовтИсп.ПолучитьUOMПоКоду(СтрокаPOLine.КодЕдиницыИзмерения);
				Если ЗначениеЗаполнено(UOM) Тогда
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ЕдиницаИзмерения, UOM);
				Иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to find UOM by code """ + СтрокаPOLine.КодЕдиницыИзмерения + """!",
						,,, Отказ);
				КонецЕсли;
				
				// Валюта
				НаименованиеВалюты = СтрокаPOLine.НаименованиеВалюты;
				Если НаименованиеВалюты = "RUB" ИЛИ НаименованиеВалюты = "RUR" Тогда
					НаименованиеВалюты = "RUB";
				КонецЕсли;
				Валюта = CustomsСерверПовтИсп.ПолучитьВалютуПоНаименованию(НаименованиеВалюты);
				Если ЗначениеЗаполнено(Валюта) Тогда
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.Валюта, Валюта);
				Иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to find currency by name """ + НаименованиеВалюты + """!",
						,,, Отказ);
				КонецЕсли;
										
				// AU
				Если ЭтоLawsonКомпания Тогда
					
					Если ЭтоOracleERP Тогда  // S-I-0001017
						
						РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.КостЦентр, АльтернативныйAU);
						
					иначе
						
						КодAU = Прав("0000000" + СтрокаPOLine.КодAU, 7);
						СтруктураПоискаПоКоду.Код = КодAU;
						НайденныеAUs = Объект.КешAUs.НайтиСтроки(СтруктураПоискаПоКоду);
						Если НайденныеAUs.Количество() > 0 Тогда
							РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.КостЦентр, НайденныеAUs[0].Ссылка);
						Иначе
							//-> RG-Soft VIvanov 2015/02/18
							НайденныйAU = РГСофт.НайтиAU(ДатаЗаявкиНаЗакупку, КодAU);
							Если НайденныйAU <> Неопределено Тогда
								РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.КостЦентр, НайденныйAU);
							Иначе
							//<- RG-Soft VIvanov
							
								ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
									"PO line """ + КодСтрокиPO + """: failed to find AU by code """ + КодAU + """!",
									,,, Отказ);
							КонецЕсли;
						КонецЕсли;
						
					КонецЕсли;

					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.АктивитиКод, СтрокаPOLine.АктивитиКод);
					
				Иначе
					
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.АктивитиКод, АльтернативныйAC);				
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.КостЦентр, АльтернативныйAU);

				КонецЕсли;					
				
				// Классификатор
				КлассификаторТекст = СтрокаPOLine.Классификатор;
				Если КлассификаторТекст = "n/a" Тогда
					КлассификаторТекст = "E";
				КонецЕсли;	
				
				Если ЗначениеЗаполнено(КлассификаторТекст) Тогда
					
					Попытка	
						РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.Классификатор, Перечисления.ТипыЗаказа[КлассификаторТекст]);
					Исключение
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
							"PO line """ + КодСтрокиPO + """: failed to find ERP Accounting Treatment by code """ + КлассификаторТекст + """!",
							,,, Отказ);
					КонецПопытки;
					
				КонецЕсли;
				
				// Цена, Количество, суммы
				Попытка
					КоличествоЧисло = Число(СтрокаPOLine.Количество);
					КоличествоЧисло = Окр(КоличествоЧисло, 2);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.Количество, КоличествоЧисло);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to convert """ + СтрокаPOLine.Количество + """ to Qty!",
						,,, Отказ);
				КонецПопытки;
				
			    Попытка
					ЦенаЧисло = Число(СтрокаPOLine.Цена);
					ЦенаЧисло = Окр(ЦенаЧисло, 4);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.Цена, ЦенаЧисло);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to convert """ + СтрокаPOLine.Цена + """ to Price!",
						,,, Отказ);
				КонецПопытки;
				
				Попытка
					ИтогоПоСтрокеЧисло = Число(СтрокаPOLine.ИтогоПоСтроке);
					ИтогоПоСтрокеЧисло = Окр(ИтогоПоСтрокеЧисло, 2);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ИтогоПоСтроке, ИтогоПоСтрокеЧисло);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to convert """ + СтрокаPOLine.ИтогоПоСтроке + """ to Total price!",
						,,, Отказ);
				КонецПопытки;
				
				Попытка
					ИтогоПоСтрокеДоллЧисло = Число(СтрокаPOLine.ИтогоПоСтрокеДолл);
					ИтогоПоСтрокеДоллЧисло = Окр(ИтогоПоСтрокеДоллЧисло, 2);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ИтогоПоСтрокеДолл, ИтогоПоСтрокеДоллЧисло);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"PO line """ + КодСтрокиPO + """: failed to convert """ + СтрокаPOLine.ИтогоПоСтрокеДолл + """ to Total USD price!",
						,,, Отказ);
				КонецПопытки;
				
				// МОЖЕТ БЫТЬ УДАЛИТЬ?
				Если СтрокаPOLine.ТипЗапроса = "Catalog"
					И (СтрокаPO.ТипПоставщика = "Internal" ИЛИ СтрокаPO.ТипПоставщика = "External Global")
					И СтрокаPO.СтранаПоставщика <> "Russian Federation" Тогда
					
					Каталог = ПолучитьЭлементКаталога(СтрокаPOLine.КодПоставщика, СтрокаPOLine.ОписаниеНоменклатуры);
					Если ЗначениеЗаполнено(Каталог) Тогда
						РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.Каталог, Каталог);
					Иначе
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
							"PO line """ + КодСтрокиPO + """: failed to find Catalog item!""",
							,,, Отказ);
					КонецЕсли;
				
				КонецЕсли;
				
				Если НЕ Отказ Тогда
					
					// Обработаем поля, в которых не может возникнуть ошибка
					
					// Расходы
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.НазначениеРасходов, СтрокаPOLine.НазначениеРасходов);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ТипНазначенияРасходов, СтрокаPOLine.ТипНазначенияРасходов);
						
					// Тип запроса
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ТипЗапроса, СтрокаPOLine.ТипЗапроса);
						
					// Код поставщика
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.КодПоставщика, СтрокаPOLine.КодПоставщика);
						
					// Номенклатура
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.Наименование, СтрокаPOLine.ОписаниеНоменклатуры);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ОписаниеНоменклатуры, СтрокаPOLine.ОписаниеНоменклатуры);
									
					// Перевозка и т. д.
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.СпособПеревозки, СтрокаPOLine.СпособПеревозки);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.ИнструкцииПоТранспортировке, СтрокаPOLine.ИнструкцииПоТранспортировке);
					РГСофтКлиентСервер.УстановитьЗначение(СтрокаPOОбъект.СпециальныеИнструкции, СтрокаPOLine.СпециальныеИнструкции);

					Если СтрокаPOОбъект.Модифицированность() Тогда
						Попытка
							СтрокаPOОбъект.Записать();
						Исключение
							ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
								"Failed to save PO line """ + СтрокаPOОбъект + """:
									|" + ОписаниеОшибки(),
								,,, Отказ);
						КонецПопытки;
					КонецЕсли; 
					
				КонецЕсли;
		
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла; // Цикл по строкам

	Если Отказ Тогда
		ОтменитьТранзакцию();
		ВызватьИсключение "Failed to load POs";
	КонецЕсли;
	
	ЗафиксироватьТранзакцию();
		
КонецПроцедуры

&НаСервере
Функция ЗаполнитьКешBORGs()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	BORGs.Ссылка,
		|	BORGs.Код,
		|	BORGs.Компания.Lawson КАК Lawson,
		|	BORGs.DefaultAU,
		|	BORGs.OracleERP,
		|	BORGs.DefaultAU.DefaultActivity КАК DefaultAC
		|ИЗ
		|	Справочник.BORGs КАК BORGs
		|ГДЕ
		|	НЕ BORGs.ПометкаУдаления";
		
	Выборка = Запрос.Выполнить().Выбрать();	
	Объект.КешBORGs.Очистить();
	Пока Выборка.Следующий() Цикл
		
		НоваяСтрокаКэша = Объект.КешBORGs.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрокаКэша, Выборка, "Ссылка, Код, Lawson, DefaultAU, DefaultAC, OracleERP");
		НоваяСтрокаКэша.Код = СокрП(НоваяСтрокаКэша.Код);
		
	КонецЦикла;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПреобразоватьСтрокуВДату(Знач Строка)
	
	Строка = СтрЗаменить(Строка, ":", "");
	Строка = СтрЗаменить(Строка, "-", "");
	Строка = СтрЗаменить(Строка, " ", "");
	Строка = СтрЗаменить(Строка, Символы.НПП, "");
	
	Попытка
		Дата = Дата(Строка);
		Возврат Дата;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьЭлементКаталога(КодДляПоиска, НаименованиеЕслиНет)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Результат = Справочники.Catalog.НайтиПоКоду(КодДляПоиска);
	Если Результат.Пустая() Тогда
		
		КаталогОбъект = Справочники.Catalog.СоздатьЭлемент();
		КаталогОбъект.Код = КодДляПоиска;
		КаталогОбъект.DescriptionEng = НаименованиеЕслиНет;
				
		Попытка
			КаталогОбъект.Записать();
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось записать элемент каталога """ + КаталогОбъект + """!");
				Возврат Неопределено;
		КонецПопытки;
		
		Результат = КаталогОбъект.Ссылка;
		
	иначе
		
		//S-I-0001299
		КаталогОбъект = Результат.ПолучитьОбъект();
		РГСофтКлиентСервер.УстановитьЗначение(КаталогОбъект.DescriptionEng, СокрЛП(НаименованиеЕслиНет));
		
		Если КаталогОбъект.Модифицированность() Тогда 
			
			Попытка
				КаталогОбъект.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось обновить элемент каталога """ + КаталогОбъект + """!");
				Возврат Неопределено;
			КонецПопытки;
			
		КонецЕсли;
	
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат Результат;
	             	
КонецФункции


//////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕЩЕНИЕ В ПАПКУ DONE

&НаКлиенте
Процедура ПереместитьФайлВПапкуDone(ПолноеИмяФайла)
	
	Файл = Новый Файл(ПолноеИмяФайла);
	
	ПапкаDone = Новый Файл(Файл.Путь + "Done");	
	Если НЕ ПапкаDone.Существует() Тогда
		СоздатьКаталог(ПапкаDone.ПолноеИмя);
	КонецЕсли;
	
	ПереместитьФайл(ПолноеИмяФайла, ПапкаDone.ПолноеИмя + "\" + Файл.Имя);	
		
КонецПроцедуры
