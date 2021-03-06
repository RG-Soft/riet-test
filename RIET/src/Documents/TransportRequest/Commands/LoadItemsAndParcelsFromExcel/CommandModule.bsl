
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
		
	Если СозданыItemsParcels(ПараметрКоманды) Тогда 
		
		ПоказатьВопрос(
		Новый ОписаниеОповещения("ОбработкаКомандыLoadItemsAndParcelsFromExcelЗавершение", 
		ЭтотОбъект, ПараметрКоманды),
		?(РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS(),
		"Текущая заявка уже содержит данные по товарам / грузовым местам.
		|Добавить новые товары / грузовые места из файла?",
		"Current Transport request already includes some items / parcels. 
		|Add new parcels and items from file?"), 
		РежимДиалогаВопрос.ДаНет,
		60,
		КодВозвратаДиалога.Нет,
		,
		КодВозвратаДиалога.Нет);
		
	иначе
		
		ОбработкаКомандыLoadItemsAndParcelsFromExcelЗавершение(КодВозвратаДиалога.Да, ПараметрКоманды);
		
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция СозданыItemsParcels(TransportRequest)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TransportRequest", TransportRequest);
	Запрос.Текст = "ВЫБРАТЬ
	|	СтрокиИнвойса.Ссылка  КАК Item
	|ИЗ
	|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	|ГДЕ
	|	СтрокиИнвойса.TransportRequest = &TransportRequest
	|	И НЕ СтрокиИнвойса.ПометкаУдаления
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Parcels.Ссылка
	|ИЗ
	|	Справочник.Parcels КАК Parcels
	|ГДЕ
	|	Parcels.TransportRequest = &TransportRequest
	|	И НЕ Parcels.ПометкаУдаления";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка.Следующий();	

КонецФункции

&НаКлиенте
Процедура ОбработкаКомандыLoadItemsAndParcelsFromExcelЗавершение(Результат, ПараметрКоманды) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	//{ RGS AArsentev 28.03.2017 S-I-0002785
	#Если ВебКлиент Тогда
	
	НачатьПомещениеФайла(Новый ОписаниеОповещения("ЗагрузитьОповещения", ЭтотОбъект, ПараметрКоманды),,,Истина,);
	
	#Иначе
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsm (*.xlsm)'") + "|*.xlsm" );
	НастройкиДиалога.Вставить("TransportRequest", ПараметрКоманды);
	
	Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект, ПараметрКоманды);
	ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
	#КонецЕсли
	//} RGS AArsentev 28.03.2017 S-I-0002785
	
КонецПроцедуры

#Если ВебКлиент Тогда

&НаКлиенте
Процедура ОбработкаПодключениеРасширенияРаботыСФайламиЗавершение(Результат, ПараметрКоманды) Экспорт 
	
	Если Не Результат Тогда 
		НачатьУстановкуРасширенияРаботыСФайлами();
		НачатьПодключениеРасширенияРаботыСФайлами(Новый ОписаниеОповещения("ОбработкаУстановкиРасширенияРаботыСФайлами", ЭтотОбъект, ПараметрКоманды));
	Иначе
		Сообщение = новый СообщениеПользователю;
		Сообщение.Текст = "Расширение для работы с файлами подключено";
		Сообщение.Сообщить();
	КонецЕсли;

КонецПроцедуры
&НаКлиенте
Процедура ОбработкаУстановкиРасширенияРаботыСФайлами(Результат, ПараметрКоманды) Экспорт
	
	Если Не Результат Тогда
		Сообщение = новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось подключить расширение для работы с файлами";
		Сообщение.Сообщить();
	Иначе
		Сообщение = новый СообщениеПользователю;
		Сообщение.Текст = "Расширение для работы с файлами подключено";
		Сообщение.Сообщить();
	конецЕсли;
	
конецпроцедуры


#КонецЕсли	


&НаКлиенте
Процедура LoadFile(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	#Если ВебКлиент Тогда
		АдресФайла = ПоместитьВоВременноеХранилище(РезультатПомещенияФайлов);	
	#Иначе	
		АдресФайла = РезультатПомещенияФайлов.Хранение;
	#КонецЕсли
	РасширениеФайла = "xlsm";
	ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
	Оповестить("LoadItemsAndParcelsFromExcel");
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, TransportRequest)
	
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);

	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);

	ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла, TransportRequest);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла, TransportRequest)  
	
	ТекстОшибок = "";
	
	// { RGS ASeryakov 24.08.2018 14:23:19 S-I-0005903
	//ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла);
	
	CustomUnionTransaction = ОбщегоНазначения.ПолучитьЗначениеРеквизита(TransportRequest, "CustomUnionTransaction");
	ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла, CustomUnionTransaction);
	// } RGS ASeryakov 24.08.2018 14:23:19 S-I-0005903
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, TransportRequest);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла, CustomUnionTransaction)
	
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
	
	// { RGS ASeryakov, 24.08.2018 14:23:17 S-I-0005903
	CustomFile = Неопределено;
	rs.Close();
	sqlStr = "SELECT TOP 1 * FROM [" + МассивЛистов[0] + "]";
	rs.Open(sqlStr);
	CustomFile = rs.Fields.Count() = 19;
	
	Если CustomUnionTransaction И НЕ CustomFile Тогда
		
		ТекстОшибок = НСтр("ru = 'Файл не предназначен для загрузки товаров документа по таможенному союзу ЕАЭС!'; en = 'The file is not intended for loading the goods of the document on the customs Union of the EAEU!'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибок,,,, Истина);
		
	ИначеЕсли НЕ CustomUnionTransaction И CustomFile Тогда
		
		ТекстОшибок = НСтр("ru = 'Файл не предназначен для загрузки товаров документа!'; en = 'The file is not intended for loading the goods of the document!'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибок,,,,Истина);
		
	КонецЕсли;
	// } RGS ASeryakov, 24.08.2018 14:23:17 S-I-0005903
	
	ТаблицаExcel = Новый ТаблицаЗначений();
	ТаблицаExcel.Колонки.Добавить("НомерСтрокиФайла", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(5, 0)),"НомерСтрокиФайла");
		
	Для Каждого ЛистЭксель из МассивЛистов Цикл 
		
		sqlString = "select * from [" + ЛистЭксель + "]";
		rs.Close();
		rs.Open(sqlString);
		
		rs.MoveFirst();
		
		// { RGS ASeryakov, 24.08.2018 14:23:17 S-I-0005903
		//СвойстваСтруктуры = "ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ,ТИП_УПАКОВКИ,КОЛИЧЕСТВО_УПАКОВОК,ДЛИНА_СМ,ШИРИНА_СМ,ВЫСОТА_СМ,ВЕС_БРУТТО_КГ,КЛАСС_ОПАСНОСТИ,"+
		//"СЕРИЙНЫЙ_НОМЕР,АРТИКУЛ,ОПИСАНИЕ_РУС,ОПИСАНИЕ_АНГЛ,КЛАССИФИКАЦИЯ,КОЛИЧЕСТВО,ЕДИНИЦА_ИЗМЕРЕНИЯ";
		
		Если НЕ CustomUnionTransaction Тогда
			СвойстваСтруктуры = "ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ,ТИП_УПАКОВКИ,КОЛИЧЕСТВО_УПАКОВОК,ДЛИНА_СМ,ШИРИНА_СМ,ВЫСОТА_СМ,ВЕС_БРУТТО_КГ,КЛАСС_ОПАСНОСТИ,"+
			"СЕРИЙНЫЙ_НОМЕР,АРТИКУЛ,ОПИСАНИЕ_РУС,ОПИСАНИЕ_АНГЛ,КЛАССИФИКАЦИЯ,КОЛИЧЕСТВО,ЕДИНИЦА_ИЗМЕРЕНИЯ";
		Иначе
			СвойстваСтруктуры = "ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ,ТИП_УПАКОВКИ,КОЛИЧЕСТВО_УПАКОВОК,ДЛИНА_СМ,ШИРИНА_СМ,ВЫСОТА_СМ,ВЕС_БРУТТО_КГ,КЛАСС_ОПАСНОСТИ,"+
			"СЕРИЙНЫЙ_НОМЕР,АРТИКУЛ,ОПИСАНИЕ_РУС,ОПИСАНИЕ_АНГЛ,КЛАССИФИКАЦИЯ,КОЛИЧЕСТВО,ЕДИНИЦА_ИЗМЕРЕНИЯ,СТРАНА_ПРОИСХОЖДЕНИЯ,ЦЕНА,ВАЛЮТА,ТНВЭД";
		КонецЕсли;
		// } RGS ASeryakov 24.08.2018 14:23:19 S-I-0005903

		
		НомерСтроки = 0;
		Пока rs.EOF = 0 Цикл
			
			НомерСтроки = НомерСтроки + 1;
			
			Если НомерСтроки = 1 Тогда 
				// { RGS ASeryakov, 24.08.2018 14:23:17 S-I-0005903
				//СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок);
				СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок, CustomUnionTransaction);
				// } RGS ASeryakov, 24.08.2018 14:23:17 S-I-0005903
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
			
			Если Не ЗначениеЗаполнено(СтруктураЗначенийСтроки.ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ) Тогда 
				
				Если ТаблицаExcel.Количество() = 0 Тогда
					Сообщить("В файле нет данных для загрузки!");
				КонецЕсли;
				
				Прервать;
				
			КонецЕсли;     			        						
			
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
Функция ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок, CustomUnionTransaction)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Для Каждого Field из rs.Fields Цикл 
		
		ТекстЯчейки = СокрЛП(Field.Value);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли; 
		
		Если ТекстЯчейки = "ПОРЯДКОВЫЙ НОМЕР УПАКОВКИ" Тогда
			СтруктураКолонокИИндексов.ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ТИП УПАКОВКИ" Тогда
			СтруктураКолонокИИндексов.ТИП_УПАКОВКИ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "КОЛИЧЕСТВО УПАКОВОК" Тогда
			СтруктураКолонокИИндексов.КОЛИЧЕСТВО_УПАКОВОК = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ДЛИНА СМ" Тогда
			СтруктураКолонокИИндексов.ДЛИНА_СМ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ШИРИНА СМ" Тогда
			СтруктураКолонокИИндексов.ШИРИНА_СМ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ВЫСОТА СМ" Тогда
			СтруктураКолонокИИндексов.ВЫСОТА_СМ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ВЕС БРУТТО КГ" Тогда
			СтруктураКолонокИИндексов.ВЕС_БРУТТО_КГ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "КЛАСС ОПАСНОСТИ" Тогда
			СтруктураКолонокИИндексов.КЛАСС_ОПАСНОСТИ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "СЕРИЙНЫЙ НОМЕР" Тогда
			СтруктураКолонокИИндексов.СЕРИЙНЫЙ_НОМЕР = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "АРТИКУЛ" Тогда
			СтруктураКолонокИИндексов.АРТИКУЛ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ОПИСАНИЕ РУС" Тогда
			СтруктураКолонокИИндексов.ОПИСАНИЕ_РУС = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ОПИСАНИЕ АНГЛ" Тогда
			СтруктураКолонокИИндексов.ОПИСАНИЕ_АНГЛ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "КЛАССИФИКАЦИЯ" Тогда
			СтруктураКолонокИИндексов.КЛАССИФИКАЦИЯ = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "КОЛИЧЕСТВО" Тогда
			СтруктураКолонокИИндексов.КОЛИЧЕСТВО = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "ЕДИНИЦА ИЗМЕРЕНИЯ" Тогда
			СтруктураКолонокИИндексов.ЕДИНИЦА_ИЗМЕРЕНИЯ = НомерКолонки;
		//ИначеЕсли ТекстЯчейки = "ВЕС НЕТТО КГ" Тогда
		//	СтруктураКолонокИИндексов.ВЕС_НЕТТО_КГ = НомерКолонки;
		
		КонецЕсли;
		
		// { RGS ASeryakov, 24.08.2018 15:21:25 S-I-0005903
		Если CustomUnionTransaction Тогда
			Если ТекстЯчейки = "СТРАНА ПРОИСХОЖДЕНИЯ" Тогда
				СтруктураКолонокИИндексов.СТРАНА_ПРОИСХОЖДЕНИЯ = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "ЦЕНА" Тогда
				СтруктураКолонокИИндексов.ЦЕНА = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "ВАЛЮТА" Тогда
				СтруктураКолонокИИндексов.ВАЛЮТА = НомерКолонки;
			ИначеЕсли ТекстЯчейки = "ТНВЭД" Тогда
				СтруктураКолонокИИндексов.ТНВЭД = НомерКолонки;
			КонецЕсли;
		КонецЕсли;
		// } RGS ASeryakov 24.08.2018 15:21:27 S-I-0005903
	
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
Процедура ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, TransportRequest) 
	
	Отказ = Ложь;
	
	МассивParcelNo = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаExcel, "ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ");
	СтруктураПоискаПоParcelNo = Новый Структура("ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ");
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	Для Каждого ParcelNo из МассивParcelNo Цикл 
		
		СтруктураПоискаПоParcelNo.ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ = ParcelNo;
		
		ТаблицаДляСозданияParcel = ТаблицаExcel.Скопировать(СтруктураПоискаПоParcelNo);
		
		СоздатьParcelИзТаблицы(Отказ, ТаблицаДляСозданияParcel, TransportRequest);	
		
	КонецЦикла;
	
	Если Отказ Тогда 
		ОтменитьТранзакцию();
		Сообщить("Были ошибки. Данные не загружены!", СтатусСообщения.ОченьВажное);
	Иначе
		ЗафиксироватьТранзакцию();
		Сообщить("Данные успешно загружены.", СтатусСообщения.Информация);
	КонецЕсли;
		
КонецПроцедуры

&НаСервере	
Процедура СоздатьParcelИзТаблицы(Отказ, ТаблицаДляСозданияParcel, TransportRequest)
	
	ПерваяСтрокаТаблицы = ТаблицаДляСозданияParcel[0];   	
	            			
	ParcelОбъект = ЗаполнитьШапкуParcel(Отказ, ParcelОбъект, ПерваяСтрокаТаблицы, TransportRequest);
	
	ЗаполнитьТЧДеталиParcel(Отказ, ТаблицаДляСозданияParcel, ParcelОбъект, TransportRequest);
	 			
	Если НЕ Отказ Тогда
		
		Попытка
			//ParcelОбъект.NetWeight = ParcelОбъект.Детали.Итог("NetWeight");
			ParcelОбъект.Записать();
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось записать грузовое место " + ПерваяСтрокаТаблицы.ПОРЯДКОВЫЙ_НОМЕР_УПАКОВКИ + " в строке файла №" + СокрЛП(ПерваяСтрокаТаблицы.НомерСтрокиФайла)+": " + ОписаниеОшибки(),
				, , , Отказ)
		КонецПопытки;
		
	КонецЕсли; 
		
КонецПроцедуры

&НаСервере
Функция ЗаполнитьШапкуParcel(Отказ, ParcelОбъект, СтрокаParcel, TransportRequest);
	
	ParcelОбъект = Справочники.Parcels.СоздатьЭлемент(); 
	ParcelОбъект.TransportRequest = TransportRequest;

	ParcelОбъект.LocalOnly = Истина;
	ParcelОбъект.Проверен  = Истина;
		                                                                   		
	ParcelОбъект.PackingType = Справочники.PackingTypes.НайтиПоРеквизиту("CodeRus", СтрокаParcel.ТИП_УПАКОВКИ);  	
	Если Не ЗначениеЗаполнено(ParcelОбъект.PackingType) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось найти ТИП УПАКОВКИ с кодом " + СтрокаParcel.ТИП_УПАКОВКИ + " в строке файла №" + СокрЛП(СтрокаParcel.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;  
	
	Попытка
		ParcelОбъект.NumOfParcels = Число(СтрокаParcel.КОЛИЧЕСТВО_УПАКОВОК); 
	Исключение
	КонецПопытки;
	
	Если Не ЗначениеЗаполнено(ParcelОбъект.NumOfParcels) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось преобразовать в число значение КОЛИЧЕСТВО УПАКОВОК " + СокрЛП(СтрокаParcel.КОЛИЧЕСТВО_УПАКОВОК) + " в строке файла №" + СокрЛП(СтрокаParcel.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;
		
	//DIMs CM	
	ParcelОбъект.DIMsUOM = Справочники.UOMs.CM;
	
	Попытка
	ParcelОбъект.Length = Число(СтрокаParcel.ДЛИНА_СМ); 
	Исключение
	КонецПопытки;

	Если Не ЗначениеЗаполнено(ParcelОбъект.Length) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось преобразовать в число значение ДЛИНА СМ " + СокрЛП(СтрокаParcel.ДЛИНА_СМ) + " в строке файла №" + СокрЛП(СтрокаParcel.НомерСтрокиФайла),
			, , , Отказ);
	Иначе 
		ParcelОбъект.LengthCM = ParcelОбъект.Length;  	
	КонецЕсли;

	Попытка
	ParcelОбъект.Width = Число(СтрокаParcel.ШИРИНА_СМ);  
	Исключение
	КонецПопытки;

	Если Не ЗначениеЗаполнено(ParcelОбъект.Width) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось преобразовать в число значение ШИРИНА СМ " + СокрЛП(СтрокаParcel.ШИРИНА_СМ) + " в строке файла №" + СокрЛП(СтрокаParcel.НомерСтрокиФайла),
			, , , Отказ);
	Иначе 
		ParcelОбъект.WidthCM = ParcelОбъект.Width;  	
	КонецЕсли;

	Попытка
	ParcelОбъект.Height = Число(СтрокаParcel.ВЫСОТА_СМ);  
	Исключение
	КонецПопытки;

	Если Не ЗначениеЗаполнено(ParcelОбъект.Height) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось преобразовать в число значение ВЫСОТА СМ " + СокрЛП(СтрокаParcel.ВЫСОТА_СМ) + " в строке файла №" + СокрЛП(СтрокаParcel.НомерСтрокиФайла),
			, , , Отказ);
	Иначе 
		ParcelОбъект.HeightCM = ParcelОбъект.Height;  	
	КонецЕсли;

	// WEIGHT KG
	ParcelОбъект.WeightUOM = Справочники.UOMs.KG;
	
	Попытка
	ParcelОбъект.GrossWeight = Число(СтрокаParcel.ВЕС_БРУТТО_КГ); 
	Исключение
	КонецПопытки;

	Если Не ЗначениеЗаполнено(ParcelОбъект.GrossWeight) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Не удалось преобразовать в число ВЕС БРУТТО КГ " + СокрЛП(СтрокаParcel.ВЕС_БРУТТО_КГ) + " в строке файла №" + СокрЛП(СтрокаParcel.НомерСтрокиФайла),
		, , , Отказ);
	иначе
		ParcelОбъект.GrossWeightKG = ParcelОбъект.GrossWeight; 
	КонецЕсли;

	Возврат ParcelОбъект;
	
КонецФункции 

&НаСервере
Процедура ЗаполнитьТЧДеталиParcel(Отказ, ТаблицаДляСозданияParcel, ParcelОбъект, TransportRequest)
	
	Для Каждого СтрокаItem из ТаблицаДляСозданияParcel Цикл
		   				
		СтрокаТЧ = ParcelОбъект.Детали.Добавить();

		СтрокаТЧ.СтрокаИнвойса = ПолучитьInvoiceLineДляСтрокиParcel(Отказ, СтрокаItem, TransportRequest);
				
		СтруктураРеквизитовItem = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаТЧ.СтрокаИнвойса, "СерийныйНомер,Количество,ЕдиницаИзмерения,HazardClass");
			
		СтрокаТЧ.Qty = СтруктураРеквизитовItem.Количество;
		СтрокаТЧ.QtyUOM = СтруктураРеквизитовItem.ЕдиницаИзмерения;
		СтрокаТЧ.СерийныйНомер = СтруктураРеквизитовItem.СерийныйНомер;
		//СтрокаТЧ.NetWeight = СтруктураРеквизитовItem.NetWeight;
		
		ParcelОбъект.HazardClass = СтруктураРеквизитовItem.HazardClass;
		
	КонецЦикла;  		
	
КонецПроцедуры 

&НаСервере
Функция ПолучитьInvoiceLineДляСтрокиParcel(Отказ, СтрокаItem, TransportRequest)
	
	InvoiceLineОбъект = Справочники.СтрокиИнвойса.СоздатьЭлемент();
	InvoiceLineОбъект.LocalOnly = Истина;
	InvoiceLineОбъект.TransportRequest = TransportRequest;
	
	InvoiceLineОбъект.HazardClass = Справочники.HazardClasses.НайтиПоКоду(СтрокаItem.КЛАСС_ОПАСНОСТИ);  	
	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.HazardClass) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось найти КЛАСС ОПАСНОСТИ с кодом " + СтрокаItem.КЛАСС_ОПАСНОСТИ + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;
	
	InvoiceLineОбъект.КодПоИнвойсу = СтрокаItem.АРТИКУЛ;  	
	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.КодПоИнвойсу) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнен АРТИКУЛ в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;

	InvoiceLineОбъект.СерийныйНомер = СтрокаItem.СЕРИЙНЫЙ_НОМЕР;  
	
	InvoiceLineОбъект.DescriptionRus = СтрокаItem.ОПИСАНИЕ_РУС;  	
	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.DescriptionRus) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено ОПИСАНИЕ РУС в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;

	InvoiceLineОбъект.НаименованиеТовара = СтрокаItem.ОПИСАНИЕ_АНГЛ;  	
	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.НаименованиеТовара) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено ОПИСАНИЕ АНГЛ в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;

	InvoiceLineОбъект.ERPTreatmentNonLawson = Справочники.ERPTreatments.НайтиПоНаименованию(СтрокаItem.КЛАССИФИКАЦИЯ);  	
	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.ERPTreatmentNonLawson) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось определить КЛАССИФИКАЦИЮ по коду " + СтрокаItem.КЛАССИФИКАЦИЯ + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;

	Попытка
	InvoiceLineОбъект.Количество = Число(СтрокаItem.КОЛИЧЕСТВО); 
	Исключение
	КонецПопытки;

	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.Количество) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось преобразовать в число значение КОЛИЧЕСТВО " + СтрокаItem.КОЛИЧЕСТВО + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;

	InvoiceLineОбъект.ЕдиницаИзмерения = Справочники.UOMs.НайтиПоРеквизиту("NameRus", СтрокаItem.ЕДИНИЦА_ИЗМЕРЕНИЯ);  	
	Если Не ЗначениеЗаполнено(InvoiceLineОбъект.ЕдиницаИзмерения) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось найти ЕДИНИЦУ ИЗМЕРЕНИЯ с кодом " + СтрокаItem.ЕДИНИЦА_ИЗМЕРЕНИЯ + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
	КонецЕсли;
	
	//Попытка
	//InvoiceLineОбъект.NetWeight = Число(СтрокаItem.ВЕС_НЕТТО_КГ);
	//Исключение
	//КонецПопытки;

	//Если Не ЗначениеЗаполнено(InvoiceLineОбъект.NetWeight) Тогда 
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//		"Не удалось преобразовать в число значение ВЕС НЕТТО КГ " + СтрокаItem.ВЕС_НЕТТО_КГ + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
	//		, , , Отказ);
	//КонецЕсли;

	// { RGS ASeryakov, 24.08.2018 14:41:58 S-I-0005903
	Если ОбщегоНазначения.ПолучитьЗначениеРеквизита(TransportRequest,"CustomUnionTransaction") Тогда
		
		InvoiceLineОбъект.СтранаПроисхождения = Справочники.CountriesHUBs.НайтиПоКоду(СтрокаItem.СТРАНА_ПРОИСХОЖДЕНИЯ);
		Если Не ЗначениеЗаполнено(InvoiceLineОбъект.СтранаПроисхождения) Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось найти СТРАНУ_ПРОИСХОЖДЕНИЯ с кодом " + СтрокаItem.СТРАНА_ПРОИСХОЖДЕНИЯ + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
		КонецЕсли;
		
		Попытка
			
			InvoiceLineОбъект.Цена = Число(СтрокаItem.ЦЕНА);
			
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(InvoiceLineОбъект.Цена) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось преобразовать в число значение ЦЕНА " + СтрокаItem.ЦЕНА + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
		КонецЕсли;
		
		InvoiceLineОбъект.Currency = Справочники.Валюты.НайтиПоКоду(СтрокаItem.ВАЛЮТА);
		Если Не ЗначениеЗаполнено(InvoiceLineОбъект.Currency) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось найти ВАЛЮТУ с кодом " + СтрокаItem.ВАЛЮТА + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
		КонецЕсли;
		
		InvoiceLineОбъект.TNVED = Справочники.TNVEDCodes.НайтиПоКоду(СтрокаItem.ТНВЭД);
		Если Не ЗначениеЗаполнено(InvoiceLineОбъект.TNVED) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не удалось найти ТНВЭД с кодом " + СтрокаItem.ТНВЭД + " в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла),
			, , , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	// } RGS ASeryakov 24.08.2018 14:42:00 S-I-0005903
	
	
	InvoiceLineОбъект.WeightUOM = Справочники.UOMs.KG;
	
	Если Не Отказ Тогда 
		
		Попытка
			InvoiceLineОбъект.Записать();
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось записать товар в строке файла №" + СокрЛП(СтрокаItem.НомерСтрокиФайла)+": " + ОписаниеОшибки(),
				, , , Отказ);
		КонецПопытки;  

	КонецЕсли;

	Возврат InvoiceLineОбъект.Ссылка;
	
КонецФункции
 
&НаКлиенте
Процедура ЗагрузитьОповещения(Результат,Адрес,ИмяФайла,ДополнительныеПараметры) Экспорт
   
	Если Результат Тогда
		РасширениеФайла = "xlsm";
		ЗагрузитьДанныеНаСервере(Адрес, РасширениеФайла, ДополнительныеПараметры);
		Оповестить("LoadItemsAndParcelsFromExcel");
	КонецЕсли;
   
КонецПроцедуры