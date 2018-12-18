#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

// Обработка события ПередЗаписью.
//
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.Свойство("КонвертацияФайлов") Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ВладелецФайла) Тогда
		
		ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ВернутьСтр("ru = 'Не заполнен владелец в файле
			           |""%1"".'"),
			Наименование);
		
		Если ОбновлениеИнформационнойБазы.ВыполняетсяОбновлениеИнформационнойБазы() Тогда
			
			ЗаписьЖурналаРегистрации(
				ВернутьСтр("ru = 'Файлы.Ошибка записи файла при обновлении ИБ'",
				     ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,
				,
				Ссылка,
				ОписаниеОшибки);
		Иначе
			ВызватьИсключение ОписаниеОшибки;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЭтоНовый() Тогда
		// Проверка права "Добавление".
		Если НЕ РаботаСФайламиСлужебный.ЕстьПраво("ДобавлениеФайлов", ВладелецФайла) Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ВернутьСтр("ru = 'Недостаточно прав для добавления файлов в папку ""%1"".'"),
				Строка(ВладелецФайла));
		КонецЕсли;
	Иначе
		
		ЕстьПометкаУдаленияВИБ = ПометкаУдаленияВИБ();
		УстановленаПометкаУдаления = ПометкаУдаления И Не ЕстьПометкаУдаленияВИБ;
		ИзмененаПометкаУдаления = (ПометкаУдаления <> ЕстьПометкаУдаленияВИБ);
		
		ЗаписьПодписанногоОбъекта = Ложь;
		Если ДополнительныеСвойства.Свойство("ЗаписьПодписанногоОбъекта") Тогда
			ЗаписьПодписанногоОбъекта = ДополнительныеСвойства.ЗаписьПодписанногоОбъекта;
		КонецЕсли;
		
		Если ЗаписьПодписанногоОбъекта <> Истина Тогда
			
			СтруктураРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка,
				"ПодписанЭП, Зашифрован, Редактирует");
			
			СсылкаПодписан    = СтруктураРеквизитов.ПодписанЭП;
			СсылкаЗашифрован  = СтруктураРеквизитов.Зашифрован;
			СсылкаРедактирует = СтруктураРеквизитов.Редактирует;
			СсылкаЗанят       = ЗначениеЗаполнено(СтруктураРеквизитов.Редактирует);
			Занят = ЗначениеЗаполнено(Редактирует);
			
			Если ПодписанЭП И СсылкаПодписан И Занят И Не СсылкаЗанят Тогда
				ВызватьИсключение ВернутьСтр("ru = 'Подписанный файл нельзя редактировать.'");
			КонецЕсли;
			
			Если Зашифрован И СсылкаЗашифрован И ПодписанЭП И НЕ СсылкаПодписан Тогда
				ВызватьИсключение ВернутьСтр("ru = 'Зашифрованный файл нельзя подписывать.'");
			КонецЕсли;
			
		КонецЕсли;
		
		Если Не ТекущаяВерсия.Пустая() Тогда
			
			РеквизитыТекущейВерсии = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
				ТекущаяВерсия, "ПолноеНаименование");
			
			// Проверим равенство имени файла и его текущей версии.
			// Если имена отличаются - имя у версии должно стать как у карточки с файлом.
			Если РеквизитыТекущейВерсии.ПолноеНаименование <> ПолноеНаименование Тогда
				Объект = ТекущаяВерсия.ПолучитьОбъект();
				Если Объект <> Неопределено И Объект.Ссылка <> Неопределено Тогда
					ЗаблокироватьДанныеДляРедактирования(Объект.Ссылка);
					УстановитьПривилегированныйРежим(Истина);
					Объект.ПолноеНаименование = ПолноеНаименование;
					// Чтобы не сработала подписка СкопироватьРеквизитыВерсииФайловВФайл.
					Объект.ДополнительныеСвойства.Вставить("ПереименованиеФайла", Истина);
					Объект.Записать();
					УстановитьПривилегированныйРежим(Ложь);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
		Если ИзмененаПометкаУдаления Тогда
			
			// Проверка права "Пометка на удаление".
			Если НЕ РаботаСФайламиСлужебный.ЕстьПраво("ПометкаУдаленияФайлов", ВладелецФайла) Тогда
				ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					ВернутьСтр("ru = 'Недостаточно прав для пометки файлов на удаление в папке ""%1"".'"),
					Строка(ВладелецФайла));
			КонецЕсли;
			
			// Попытка установить пометку удаления.
			Если УстановленаПометкаУдаления И ЗначениеЗаполнено(Редактирует) Тогда
				ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					ВернутьСтр("ru = 'Нельзя удалить файл ""%1"",
					           |т.к. он занят для редактирования пользователем ""%2"".'"),
					ПолноеНаименование,
					Строка(Редактирует) );
			КонецЕсли;
			
		КонецЕсли;
		
		НаименованиеВИБ = НаименованиеВИБ();
		Если ПолноеНаименование <> НаименованиеВИБ Тогда 
			Если ЗначениеЗаполнено(Редактирует) Тогда
				ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					ВернутьСтр("ru = 'Нельзя переименовать файл ""%1"",
					           |т.к. он занят для редактирования пользователем ""%2"".'"),
					НаименованиеВИБ,
					Строка(Редактирует));
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	Наименование = СокрЛП(ПолноеНаименование);
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ЭтоНовый() Тогда
		ДатаСоздания = ТекущаяДатаСеанса();
		ХранитьВерсии = Истина;
		ИндексКартинки = ФайловыеФункцииСлужебныйКлиентСервер.ПолучитьИндексПиктограммыФайла(Неопределено);
		
		Автор = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает текущее значение пометки удаления в информационной базе.
Функция ПометкаУдаленияВИБ()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Файлы.ПометкаУдаления
		|ИЗ
		|	Справочник.Файлы КАК Файлы
		|ГДЕ
		|	Файлы.Ссылка = &Ссылка";

	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	Результат = Запрос.Выполнить();

	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.ПометкаУдаления;
	КонецЕсли;	
	
	Возврат Неопределено;
КонецФункции

// Возвращает текущее значение наименования в информационной базе.
Функция НаименованиеВИБ()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Файлы.ПолноеНаименование
	|ИЗ
	|	Справочник.Файлы КАК Файлы
	|ГДЕ
	|	Файлы.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Результат = Запрос.Выполнить();
	
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.ПолноеНаименование;
	КонецЕсли;
	
	Возврат Неопределено;	
	
КонецФункции

#КонецОбласти

#КонецЕсли
