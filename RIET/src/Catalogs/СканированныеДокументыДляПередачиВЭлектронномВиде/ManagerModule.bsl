#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
Процедура ОбработкаПолученияФормы(ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка)
	
	// инициализируем контекст ЭДО - модуль обработки
	ТекстСообщения = "";
	КонтекстЭДО = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО(ТекстСообщения);
	Если КонтекстЭДО = Неопределено Тогда 
		//ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	КонтекстЭДО.ОбработкаПолученияФормы("Справочник", "СканированныеДокументыДляПередачиВЭлектронномВиде", ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка);
	

КонецПроцедуры

Функция ОпределитьТипФайлаВложения(ОбъектФайл)
	
	нрегРасширениеФайла = нрег(ОбъектФайл.Расширение);
	Если нрегРасширениеФайла = ".tiff" ИЛИ нрегРасширениеФайла = ".tif" Тогда
		Возврат Перечисления.ТипыСодержимогоФайлов.tiff;
	ИначеЕсли нрегРасширениеФайла = ".jpeg" ИЛИ нрегРасширениеФайла = ".jpg" Тогда
		Возврат Перечисления.ТипыСодержимогоФайлов.jpeg;
	Иначе
		Возврат Перечисления.ТипыСодержимогоФайлов.Неизвестный;
	КонецЕсли;
	
КонецФункции

Функция ЗагрузитьИзВнешнегоИсточникаПоСтруктуреРезультатаВыбора(СтруктураРезультата) Экспорт
	
	МассивСсылокДобавленныхФайлов = Новый Массив;
	
	ПолноеИмяФайлаОбмена		= СтруктураРезультата.ПолноеИмяФайлаОбмена;
	РежимВыбораИзКаталога		= СтруктураРезультата.РежимВыбораИзКаталога;
	
	ОрганизацияЗагрузки			= СтруктураРезультата.ОрганизацияСсылка;
	
	ТЗЗагруженныеДокументы 	= ПолучитьИзВременногоХранилища(СтруктураРезультата.АдресТЗЗагруженныеДокументы);
	ТЗУчастникиДокументов 	= ПолучитьИзВременногоХранилища(СтруктураРезультата.АдресТЗУчастникиДокументов);
	ТЗФайлыДокументов 		= ПолучитьИзВременногоХранилища(СтруктураРезультата.АдресТЗФайлыДокументов);
	ТЗРеквизитыУчастников	= ПолучитьИзВременногоХранилища(СтруктураРезультата.АдресТЗРеквизитыУчастников);
	
	СканДокументы = Справочники.СканированныеДокументыДляПередачиВЭлектронномВиде;
	
	Если РежимВыбораИзКаталога Тогда
		
		КаталогОбмена = ПолноеИмяФайлаОбмена; // в этот каталог уже скопированы файлы из каталога обмена на клиенте
		
	Иначе
		
		КонтекстЭДОСервер = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО();
	
		КаталогОбмена = КонтекстЭДОСервер.СоздатьВременныйКаталогСервер();
	
		// Извлекаем все файлы из ZIP файла обмена
		
		Попытка
			
			ФайлОбмена = Новый Файл(ПолноеИмяФайлаОбмена);
			
			ЧтениеЗИП = Новый ЧтениеZipФайла(ПолноеИмяФайлаОбмена);	
			ЧтениеЗИП.ИзвлечьВсе(КаталогОбмена);
			
		Исключение
			
			Сообщить("Не удалось извлечь файлы из файла обмена", СтатусСообщения.Важное);
			
			Возврат Неопределено;
		КонецПопытки;
		
	КонецЕсли;
	
	// Открываем транзакцию
	НачатьТранзакцию();
	
	Для каждого СтрокаТЗЗагруженныеДокументы Из ТЗЗагруженныеДокументы Цикл
		
		НовыйЭлемент = СканДокументы.СоздатьЭлемент();
		НовыйЭлемент.Организация = ОрганизацияЗагрузки;
		НовыйЭлемент.ВидДокумента = СтрокаТЗЗагруженныеДокументы.ВидДокумента;
		НовыйЭлемент.ДатаДокумента = СтрокаТЗЗагруженныеДокументы.Дата;
		НовыйЭлемент.НомерДокумента = СтрокаТЗЗагруженныеДокументы.Номер;
		НовыйЭлемент.СуммаВсего = СтрокаТЗЗагруженныеДокументы.СуммаВсего;
		НовыйЭлемент.СуммаНалога = СтрокаТЗЗагруженныеДокументы.СуммаНалога;
		НовыйЭлемент.НомерОснования = СтрокаТЗЗагруженныеДокументы.НомерОснования;
		НовыйЭлемент.ДатаОснования = СтрокаТЗЗагруженныеДокументы.ДатаОснования;
		НовыйЭлемент.ПредметДокумента = СтрокаТЗЗагруженныеДокументы.Предмет;
		НовыйЭлемент.НачалоПериода = СтрокаТЗЗагруженныеДокументы.НачалоПериода;
		НовыйЭлемент.КонецПериода = СтрокаТЗЗагруженныеДокументы.КонецПериода;
		
		//Заполним ТЧ РеквизитыУчастников
		ПараметрыОтбораТЗУчастников = Новый Структура;
		ПараметрыОтбораТЗУчастников.Вставить("ИдентификаторДокумента", СтрокаТЗЗагруженныеДокументы.ИдентификаторДокумента);
		
		МассивУчастниковДокумента = ТЗУчастникиДокументов.НайтиСтроки(ПараметрыОтбораТЗУчастников); //массив строк ТЗ УчастникиДокументов
		Для каждого Участник Из МассивУчастниковДокумента Цикл
			НоваяСтрокаУчастник = НовыйЭлемент.РеквизитыУчастников.Добавить();	
			НоваяСтрокаУчастник.РольУчастника = Участник.Роль;
			
			//для остальных реквизитов найдем нужную строку в ТЗРеквизитыУчастников
			СтрокаРеквизитов = ТЗРеквизитыУчастников.Найти(Участник.ИдентификаторУчастника, "ИдентификаторУчастника");
			Если СтрокаРеквизитов = Неопределено Тогда
				Сообщить("Не удалось определить реквизиты одного из участников документа:
				|" + СтрокаТЗЗагруженныеДокументы.ПредставлениеДокумента, СтатусСообщения.Важное);
				
				ОтменитьТранзакцию();
				Возврат Неопределено;
			КонецЕсли;
			
			НоваяСтрокаУчастник.ЯвляетсяЮрЛицом = СтрокаРеквизитов.ЯвляетсяЮрЛицом;
			
			Если СтрокаРеквизитов.ЯвляетсяЮрЛицом Тогда
				НоваяСтрокаУчастник.ЮрЛицоНаименование = СтрокаРеквизитов.НаименованиеОрганизации;
				НоваяСтрокаУчастник.ЮрЛицоИНН = СтрокаРеквизитов.ИНН;
				НоваяСтрокаУчастник.ЮрЛицоКПП = СтрокаРеквизитов.КПП;
				
			Иначе
				
				НоваяСтрокаУчастник.ФизЛицоИНН 		= СтрокаРеквизитов.ИНН;
				НоваяСтрокаУчастник.ФизЛицоФамилия 	= СтрокаРеквизитов.ФамилияИП;
				НоваяСтрокаУчастник.ФизЛицоИмя 		= СтрокаРеквизитов.ИмяИП;
				НоваяСтрокаУчастник.ФизЛицоОтчество = СтрокаРеквизитов.ОтчествоИП;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Попытка
			НовыйЭлемент.Записать();
		Исключение
			Сообщить("Не удалось записать элемент справочника:
			|" + ОписаниеОшибки(), СтатусСообщения.Важное);
			
			ОтменитьТранзакцию();
			Возврат Неопределено;
		КонецПопытки;
		
		ОбъектСсылка = НовыйЭлемент.Ссылка;
		
		МассивСсылокДобавленныхФайлов.Добавить(ОбъектСсылка);
		
		//Загрузим файлы документа
		ПараметрыОтбораТЗФайлыДокументов = Новый Структура;
		ПараметрыОтбораТЗФайлыДокументов.Вставить("ИдентификаторДокумента", СтрокаТЗЗагруженныеДокументы.ИдентификаторДокумента);
		
		МассивФайловДокумента = ТЗФайлыДокументов.НайтиСтроки(ПараметрыОтбораТЗФайлыДокументов); //массив строк ТЗФайлыДокументов
		
		// Наполняем регистр сведений ФайлыДокументовРеализацииПолномочийНалоговыхОрганов файлами
		НаборЗаписей = РегистрыСведений.ФайлыДокументовРеализацииПолномочийНалоговыхОрганов.СоздатьНаборЗаписей(); 
		НаборЗаписей.Отбор.Документ.Установить(ОбъектСсылка); 
		НаборЗаписей.Прочитать();
		
		Для каждого СтрокаТЗФайлыДокументов Из МассивФайловДокумента Цикл
			
			ИмяЗагружаемогоФайла = СтрокаТЗФайлыДокументов.ИмяНаДиске;
			
			ПолноеИмяЗагружаемогоФайла = КаталогОбмена + ИмяЗагружаемогоФайла;
			ЗагружаемыйФайл = Новый Файл(ПолноеИмяЗагружаемогоФайла);
			
			Если НЕ ЗагружаемыйФайл.Существует() Тогда
				Сообщить("В пакете обмена не обнаружен файл
				|" + ИмяЗагружаемогоФайла, СтатусСообщения.Важное);
				
				ОтменитьТранзакцию();
				Возврат Неопределено;
			КонецЕсли;
			
			РазмерФайла = ЗагружаемыйФайл.Размер();
			
			НоваяЗапись = НаборЗаписей.Добавить();
			
			НоваяЗапись.Документ = ОбъектСсылка;
			НоваяЗапись.ИмяФайла = СтрокаТЗФайлыДокументов.Имя;
			НоваяЗапись.НомерСтраницы = СтрокаТЗФайлыДокументов.НомерСтраницы;
			НоваяЗапись.ТипСодержимого = ОпределитьТипФайлаВложения(ЗагружаемыйФайл);
			НоваяЗапись.Размер = РазмерФайла;
			НоваяЗапись.Данные = Новый ХранилищеЗначения(Новый ДвоичныеДанные(ПолноеИмяЗагружаемогоФайла), Новый СжатиеДанных(9));;
			
		КонецЦикла;
		
		НаборЗаписей.Записать();
		
	КонецЦикла;
	
	// Завершаем транзакцию
	ЗафиксироватьТранзакцию();
	
	//Удаляем файлы временного каталога
	Попытка
		
		УдалитьФайлы(КаталогОбмена);
		
		Если НЕ РежимВыбораИзКаталога Тогда
			УдалитьФайлы(ПолноеИмяФайлаОбмена);
		КонецЕсли;
		
	Исключение
	КонецПопытки;
	
	Возврат МассивСсылокДобавленныхФайлов;

КонецФункции

#КонецЕсли