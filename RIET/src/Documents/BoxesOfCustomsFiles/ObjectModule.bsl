
///////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипЗнчДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
			
	Если ТипЗнчДанныхЗаполнения = Тип("Структура") Тогда
		ДанныеЗаполнения.Свойство("ProcessLevel", ProcessLevel);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");	
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойства();
	
	ДозаполнитьРеквизитыСДополнительнымиДанными(ДополнительныеСвойства.ТаблицаCustomsFiles, ДополнительныеСвойства.ТаблицаCustomsFilesLight);
			
	ПроверитьРеквизитыСДополнительнымиДанными(
		Отказ,
		ДополнительныеСвойства.ТаблицаCustomsFiles,
		ДополнительныеСвойства.ТаблицаCustomsFilesLight,
		ДополнительныеСвойства.ВыборкаCustomsFilesInOtherBoxes,
		ДополнительныеСвойства.ВыборкаCustomsFilesLightInOtherBoxes);
		
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Если ЭтоНовый() Тогда
		CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		Дата = ТекущаяДата();
	КонецЕсли;
		
	Comment = СокрЛП(Comment);
	
	CustomsFiles.Свернуть("CustomsFile", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(CustomsFiles, "CustomsFile");
	
	CustomsFilesLight.Свернуть("CustomsFileLight", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(CustomsFilesLight, "CustomsFileLight");
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Process level"" is empty!",
			ЭтотОбъект, "ProcessLevel", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(DispatchDate) Тогда
		Возврат;
	КонецЕсли;
		
	Если CustomsFiles.Количество() = 0 И CustomsFilesLight.Количество() = 0 Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Lists of Customs files and Customs files (light) are empty!",
			ЭтотОбъект, "CustomsFiles", , Отказ);		
	КонецЕсли;
					
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойства()
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Если CustomsFiles.Количество() Тогда
		
		СтруктураПараметров.Вставить("CustomsFiles", CustomsFiles.ВыгрузитьКолонку("CustomsFile"));
		СтруктураТекстов.Вставить("РеквизитыCustomsFiles",
			"ВЫБРАТЬ
			|	CustomsFiles.Ссылка КАК CustomsFile,
			|	CustomsFiles.Номер КАК No,
			|	CustomsFiles.ProcessLevel КАК ProcessLevel
			|ИЗ
			|	Документ.ГТД КАК CustomsFiles
			|ГДЕ
			|	CustomsFiles.Ссылка В(&CustomsFiles)");
			
	КонецЕсли;
	
	Если CustomsFilesLight.Количество() Тогда
		
		СтруктураПараметров.Вставить("CustomsFilesLight", CustomsFilesLight.ВыгрузитьКолонку("CustomsFileLight"));
		СтруктураТекстов.Вставить("РеквизитыCustomsFilesLight",
			"ВЫБРАТЬ
			|	CustomsFilesLight.Ссылка КАК CustomsFileLight,
			|	CustomsFilesLight.Номер КАК No,
			|	CustomsFilesLight.ProcessLevel КАК ProcessLevel
			|ИЗ
			|	Документ.CustomsFilesLight КАК CustomsFilesLight
			|ГДЕ
			|	CustomsFilesLight.Ссылка В(&CustomsFilesLight)");
			
	КонецЕсли;
	
	Если НЕ ПометкаУдаления Тогда
		
		Если CustomsFiles.Количество() Тогда
			
			СтруктураПараметров.Вставить("Ссылка", Ссылка);
			СтруктураТекстов.Вставить("CustomsFilesInOtherBoxes",
				"ВЫБРАТЬ
				|	BoxesOfCustomsFilesCustomsFiles.Ссылка.Представление КАК BoxПредставление,
				|	BoxesOfCustomsFilesCustomsFiles.CustomsFile КАК CustomsFile,
				|	BoxesOfCustomsFilesCustomsFiles.CustomsFile.Представление КАК CustomsFileПредставление
				|ИЗ
				|	Документ.BoxesOfCustomsFiles.CustomsFiles КАК BoxesOfCustomsFilesCustomsFiles
				|ГДЕ
				|	BoxesOfCustomsFilesCustomsFiles.CustomsFile В(&CustomsFiles)
				|	И BoxesOfCustomsFilesCustomsFiles.Ссылка <> &Ссылка
				|	И НЕ BoxesOfCustomsFilesCustomsFiles.Ссылка.ПометкаУдаления");
				
		КонецЕсли;
		
		Если CustomsFilesLight.Количество() Тогда
			
			СтруктураПараметров.Вставить("Ссылка", Ссылка);
			СтруктураТекстов.Вставить("CustomsFilesLightInOtherBoxes",
				"ВЫБРАТЬ
				|	BoxesOfCustomsFilesCustomsFilesLight.Ссылка.Представление КАК BoxПредставление,
				|	BoxesOfCustomsFilesCustomsFilesLight.CustomsFileLight КАК CustomsFileLight,
				|	BoxesOfCustomsFilesCustomsFilesLight.CustomsFileLight.Представление КАК CustomsFileLightПредставление
				|ИЗ
				|	Документ.BoxesOfCustomsFiles.CustomsFilesLight КАК BoxesOfCustomsFilesCustomsFilesLight
				|ГДЕ
				|	BoxesOfCustomsFilesCustomsFilesLight.CustomsFileLight В(&CustomsFilesLight)
				|	И BoxesOfCustomsFilesCustomsFilesLight.Ссылка <> &Ссылка
				|	И НЕ BoxesOfCustomsFilesCustomsFilesLight.Ссылка.ПометкаУдаления");
				
		КонецЕсли;
		
	КонецЕсли; 
			
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ТаблицаCustomsFiles", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsFiles") Тогда
		ДополнительныеСвойства.ТаблицаCustomsFiles = СтруктураРезультатов.РеквизитыCustomsFiles.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsFiles.Индексы.Добавить("CustomsFile");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаCustomsFilesLight", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsFilesLight") Тогда
		ДополнительныеСвойства.ТаблицаCustomsFilesLight = СтруктураРезультатов.РеквизитыCustomsFilesLight.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsFilesLight.Индексы.Добавить("CustomsFileLight");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаCustomsFilesInOtherBoxes", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsFilesInOtherBoxes") Тогда
		ДополнительныеСвойства.ВыборкаCustomsFilesInOtherBoxes = СтруктураРезультатов.CustomsFilesInOtherBoxes.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаCustomsFilesLightInOtherBoxes", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsFilesLightInOtherBoxes") Тогда
		ДополнительныеСвойства.ВыборкаCustomsFilesLightInOtherBoxes = СтруктураРезультатов.CustomsFilesLightInOtherBoxes.Выбрать();
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыСДополнительнымиДанными(ТаблицаCustomsFiles, ТаблицаCustomsFilesLight)
	
	ListOfCustomsFiles = "";
	
	Если CustomsFiles.Количество() Тогда
		МассивCustomsFilesNo = ТаблицаCustomsFiles.ВыгрузитьКолонку("No");
		ListOfCustomsFiles = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивCustomsFilesNo, ", ");
	КонецЕсли;		
	
	Если CustomsFilesLight.Количество() Тогда
		
		МассивCustomsFilesLightNo = ТаблицаCustomsFilesLight.ВыгрузитьКолонку("No");
		ListOfCustomsFilesLight = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивCustomsFilesLightNo, ", ");
		
		Если ЗначениеЗаполнено(ListOfCustomsFiles) Тогда
			ListOfCustomsFiles = ListOfCustomsFiles + ", ";
		КонецЕсли;
		
		ListOfCustomsFiles = ListOfCustomsFiles + ListOfCustomsFilesLight;
		
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, ТаблицаCustomsFiles, ТаблицаCustomsFilesLight, ВыборкаCustomsFilesInOtherBoxes, ВыборкаCustomsFilesLightInOtherBoxes)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 
							
	// Убедимся, что указанные Customs files еще не попадали в коробки
	Если CustomsFiles.Количество() Тогда
		
		Пока ВыборкаCustomsFilesInOtherBoxes.Следующий() Цикл
			
			СтрокаТЧ = CustomsFiles.Найти(ВыборкаCustomsFilesInOtherBoxes.CustomsFile, "CustomsFile");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""" + ВыборкаCustomsFilesInOtherBoxes.CustomsFileПредставление + """ is already in """ + ВыборкаCustomsFilesInOtherBoxes.BoxПредставление + """!",
				ЭтотОбъект, "CustomsFiles[" + (СтрокаТЧ.НомерСтроки - 1) + "].CustomsFile", , Отказ);
				
		КонецЦикла;
			
	КонецЕсли;
	
	Если CustomsFilesLight.Количество() Тогда
		
		Пока ВыборкаCustomsFilesLightInOtherBoxes.Следующий() Цикл
			
			СтрокаТЧ = CustomsFilesLight.Найти(ВыборкаCustomsFilesLightInOtherBoxes.CustomsFileLight, "CustomsFileLight");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""" + ВыборкаCustomsFilesLightInOtherBoxes.CustomsFileLightПредставление + """ is already in """ + ВыборкаCustomsFilesLightInOtherBoxes.BoxПредставление + """!",
				ЭтотОбъект, "CustomsFilesLight[" + (СтрокаТЧ.НомерСтроки - 1) + "].CustomsFileLight", , Отказ);
				
		КонецЦикла;
			
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(DispatchDate) Тогда
		Возврат;
	КонецЕсли;
	
	// Убедимся, что для все Customs files проведены и их ProcessLevels соответствуют указанному в шапке
	Для Каждого СтрокаТЧ Из CustomsFiles Цикл
		
		РеквизитыCustomsFile = ТаблицаCustomsFiles.Найти(СтрокаТЧ.CustomsFile, "CustomsFile");
		
		Если РеквизитыCustomsFile.ProcessLevel <> ProcessLevel Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Process level """ + СокрЛП(РеквизитыCustomsFile.ProcessLevel) + """ of """ + СтрокаТЧ.CustomsFile + """ differs from Process level of the Box!",
				ЭтотОбъект, "CustomsFiles[" + (СтрокаТЧ.НомерСтроки - 1) + "].CustomsFile", , Отказ);
			
		КонецЕсли;
						
	КонецЦикла; 
	
	Для Каждого СтрокаТЧ Из CustomsFilesLight Цикл
		
		РеквизитыCustomsFileLight = ТаблицаCustomsFilesLight.Найти(СтрокаТЧ.CustomsFileLight, "CustomsFileLight");
		
		Если РеквизитыCustomsFileLight.ProcessLevel <> ProcessLevel Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Process level """ + СокрЛП(РеквизитыCustomsFileLight.ProcessLevel) + """ of """ + СтрокаТЧ.CustomsFileLight + """ differs from Process level of the Box!",
				ЭтотОбъект, "CustomsFilesLight[" + (СтрокаТЧ.НомерСтроки - 1) + "].CustomsFileLight", , Отказ);
			
		КонецЕсли;
				
	КонецЦикла;
	
КонецПроцедуры
