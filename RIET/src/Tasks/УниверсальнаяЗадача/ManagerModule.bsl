
Процедура СоздатьЗадачуДляЗаполненияTaxRegistration(AccountingUnit)  Экспорт 
	       			
	ТаблицаЗадач = ПолучитьТаблицуЗадачПоОбъектуЗадачи(AccountingUnit);
		
	//получим массив иполнителей из пользователей с ролью Администратор
	МассивАдминистраторов = Новый Массив;
	
	МассивПользователейИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательИБ Из МассивПользователейИБ Цикл
		
		Если ПользовательИБ.Роли.Содержит(Метаданные.Роли.Администратор) Тогда 
			
			Пользователь = Справочники.Пользователи.НайтиПоКоду(ПользовательИБ.Имя);
			
			Если Не ЗначениеЗаполнено(Пользователь) Тогда 
				РГСофт.СообщитьИЗалоггировать(
					"Не удалось получить пользователя по коду: "+ ПользовательИБ.Имя,
					УровеньЖурналаРегистрации.Ошибка,
					Метаданные.Справочники.Пользователи,
					Неопределено);
				Продолжить;
			КонецЕсли;
			
			МассивАдминистраторов.Добавить(Пользователь);
			
		КонецЕсли;
		
	КонецЦикла;
	
	//запишем в журнал регистрации, что нет пользователей с ролью Администратор
	Если МассивАдминистраторов.Количество() = 0 Тогда 
		РГСофт.СообщитьИЗалоггировать(
			"В базе нет ни одного пользователя с ролью 'Администратор'!",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Задачи.УниверсальнаяЗадача,
			Неопределено);
	    Возврат;
	КонецЕсли;
	
	СтруктураОтбора = Новый Структура("ОбъектЗадачи,Исполнитель", AccountingUnit);
	
	Для Каждого ПользовательАдминистратор из МассивАдминистраторов Цикл 
		
		СтруктураОтбора.Исполнитель = ПользовательАдминистратор;
		
		МассивСтрок = ТаблицаЗадач.НайтиСтроки(СтруктураОтбора);
		Если МассивСтрок.Количество() > 0 Тогда 
			//значит, задача уже есть
			Продолжить;
		КонецЕсли;
		
		Задача = Задачи.УниверсальнаяЗадача.СоздатьЗадачу();
		Задача.Дата = ТекущаяДата();
		
		Задача.Наименование = "Fill Tax registration for Accounting unit: " + СокрЛП(AccountingUnit);
		Задача.ВидЗадачи = Перечисления.ВидыЗадач.FillTaxRegistration;
		Задача.ОбъектЗадачи = AccountingUnit;
		Задача.Описание = Задача.Наименование;
		Задача.СтатусУтверждения = Перечисления.СтатусыУтвержденияЗадач.НоваяЗадача;
		Задача.Исполнитель = ПользовательАдминистратор;
		Задача.Ответственный = ПользовательАдминистратор;
		
		Задача.Записать();
		
	КонецЦикла;
	  			
КонецПроцедуры

Функция ПолучитьТаблицуЗадачПоОбъектуЗадачи(ОбъектЗадачи) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ОбъектЗадачи", ОбъектЗадачи);

	Запрос.Текст = "ВЫБРАТЬ
	               |	УниверсальнаяЗадача.ОбъектЗадачи,
	               |	УниверсальнаяЗадача.Исполнитель,
	               |	УниверсальнаяЗадача.Ссылка КАК Задача
	               |ИЗ
	               |	Задача.УниверсальнаяЗадача КАК УниверсальнаяЗадача
	               |ГДЕ
	               |	УниверсальнаяЗадача.ОбъектЗадачи = &ОбъектЗадачи
	               |	И НЕ УниверсальнаяЗадача.Выполнена
	               |	И НЕ УниверсальнаяЗадача.ПометкаУдаления";
			
	Возврат Запрос.Выполнить().Выгрузить(); 
	
КонецФункции

