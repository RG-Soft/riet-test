
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

#Если не ВебКлиент Тогда
&НаКлиенте
Процедура Load(Команда)
	
	Если НЕ ЗначениеЗаполнено(FullPath) Тогда
		
		ВыбратьФайл();
		
		Если НЕ ЗначениеЗаполнено(FullPath) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Select file!",
				, "Объект", "FullPath");
				Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	 
	Состояние("File loading...");
	
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	
	Файл = Новый Файл(FullPath);
	ПолноеИмяXLSФайла = Неопределено;
	РасширениеФайла = НРег(Файл.Расширение);
	
	Если РасширениеФайла = ".xls" или РасширениеФайла = ".xlsx" Тогда
		
		ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
		КопироватьФайл(FullPath, ПолноеИмяXLSФайла);
		
	КонецЕсли; 
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ПолноеИмяXLSФайла);
	АдресФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
	  	
	ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
		
КонецПроцедуры

#КонецЕсли

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла)
	
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);

	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);
	
	Обработки.GOLDOrderStatusReportLoading.ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла);
		
КонецПроцедуры




