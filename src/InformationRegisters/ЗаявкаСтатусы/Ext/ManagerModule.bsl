﻿
Функция УстановитьСтатус(ИдентификаторСтроки, Статус, Комментарий="") Экспорт
	
	Пользователь = Пользователи.ТекущийПользователь();
	
	Если Не Справочники.СтатусыЗаявки.ПроверитьДоступСтатуса(Статус, Пользователь) Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	Запись = РегистрыСведений.ЗаявкаСтатусы.СоздатьМенеджерЗаписи();
	Запись.Период              = ТекущаяДата();
	Запись.ИдентификаторСтроки = ИдентификаторСтроки;
	Запись.Статус              = Статус;
	Запись.Комментарий         = Комментарий;
	Запись.Ответственный       = Пользователь;
	Запись.ИмяКомпьютера       = ИмяКомпьютера();
	
	Запись.Записать();
	
	Возврат Истина;
	
КонецФункции

Процедура АвтоматическийСтатус(ИдентификаторСтроки, Перечень="") Экспорт
	
	Статус = ПолучитьСтатус(ИдентификаторСтроки);
	
	Если Статус.Пустая() Тогда
		УстановитьСтатус(ИдентификаторСтроки, Справочники.СтатусыЗаявки.СтатусНачало());
	КонецЕсли;
	
	Если ПустаяСтрока(Статус.Заголовок) И (Не Статус.Следующий.Пустая() Или Не Статус["Следующий"+Перечень].Пустая()) Тогда
		УстановитьСтатус(ИдентификаторСтроки, Статус.Следующий);
	КонецЕсли;
	
КонецПроцедуры

Функция УстановитьСледующийСтатус(ИдентификаторСтроки, Перечень="", Комментарий="", Шаг="Следующий") Экспорт
	
	Статус = ПолучитьСтатус(ИдентификаторСтроки);
	
	Если Статус = Справочники.СтатусыЗаявки.СтатусОтмена() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Перечень) Тогда
		Следующий = Статус[Шаг+Перечень];
		Если Следующий.Пустая() Тогда
			Следующий = Статус[Шаг];
		КонецЕсли;
	Иначе
		Следующий = Статус[Шаг];
	КонецЕсли;
	
	Если Не Следующий.Пустая() Тогда
		Возврат УстановитьСтатус(ИдентификаторСтроки, Следующий, Комментарий);
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция УстановитьПредыдущийСтатус(ИдентификаторСтроки, Комментарий="") Экспорт
	
	//Если ПолучитьСтатус(ИдентификаторСтроки) <> Справочники.СтатусыЗаявки.СтатусОтмена() Тогда
	//	Возврат Ложь;
	//КонецЕсли;
	
	ПредыдущийСтатус = РегистрыСведений.ЗаявкаСтатусы.ПолучитьПоследнее(ПолучитьДанные(ИдентификаторСтроки)[0].Период-1, Новый Структура("ИдентификаторСтроки", ИдентификаторСтроки)).Статус;
	
	УстановитьСтатус(ИдентификаторСтроки, ПредыдущийСтатус, Комментарий);
	
КонецФункции

Функция ПолучитьДанные(ИдентификаторСтроки) Экспорт
	
	Отбор = Новый Структура("ИдентификаторСтроки", ИдентификаторСтроки);
	
	Возврат РегистрыСведений.ЗаявкаСтатусы.СрезПоследних(, Отбор);
	
КонецФункции

Функция ПолучитьСтатус(ИдентификаторСтроки) Экспорт
	
	Отбор = Новый Структура("ИдентификаторСтроки", ИдентификаторСтроки);
	
	Возврат РегистрыСведений.ЗаявкаСтатусы.ПолучитьПоследнее(, Отбор).Статус;
	
КонецФункции

Процедура ПоказатьДанныеСтатуса(Колонки, ОформлениеСтроки, Документ) Экспорт
	
	Если Колонки.ДатаСтатуса.Видимость
	 Или Колонки.СтатусЗаявки.Видимость
	 Или Колонки.ОтветственныйЗаСтатус.Видимость Тогда
	 
	 	Данные = ПолучитьДанные(Документ);
		
		Если Данные.Количество()=0 Тогда
			Возврат;
		Иначе
			ДатаСтатуса   = Данные[0].Период;
			СтатусЗаявки  = Данные[0].Статус;
			Ответственный = Данные[0].Ответственный;
			Оформление = СтатусЗаявки.Оформление.Получить();
			Если Оформление <> Неопределено Тогда 
				ЗаполнитьЗначенияСвойств(ОформлениеСтроки, Оформление);
			КонецЕсли;
		КонецЕсли;
		
		Если Колонки.ДатаСтатуса.Видимость Тогда
			ОформлениеСтроки.Ячейки.ДатаСтатуса.УстановитьТекст(ДатаСтатуса);
		КонецЕсли;
		
		Если Колонки.СтатусЗаявки.Видимость Тогда
			ОформлениеСтроки.Ячейки.СтатусЗаявки.УстановитьТекст(СтатусЗаявки);
		КонецЕсли;
		
		Если Колонки.ОтветственныйЗаСтатус.Видимость Тогда
			ОформлениеСтроки.Ячейки.ОтветственныйЗаСтатус.УстановитьТекст(Ответственный);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ИсторияСтатусов(ИдентификаторСтроки, НаТекущуюДатуОтображатьТолькоВремя=Истина) Экспорт
	
	Список = Новый СписокЗначений;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ЗаявкаСтатусы.Период КАК Период,
	|	ЗаявкаСтатусы.Статус КАК Статус,
	|	ЗаявкаСтатусы.Ответственный КАК Ответственный,
	|	ЗаявкаСтатусы.Комментарий КАК Комментарий
	|ИЗ
	|	РегистрСведений.ЗаявкаСтатусы КАК ЗаявкаСтатусы
	|ГДЕ
	|	ЗаявкаСтатусы.ИдентификаторСтроки = &ИдентификаторСтроки"
	);
	
	Запрос.УстановитьПараметр("ИдентификаторСтроки", ИдентификаторСтроки);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Период = Выборка.Период;
		Если НаТекущуюДатуОтображатьТолькоВремя Тогда
			Период = Формат(Период, ?(НачалоДня(Период) = НачалоДня(ТекущаяДата()), "ДФ=HH:mm", "ДФ=dd.MM"));
		КонецЕсли;
			
		Представление = ""+Период+Символы.Таб+Выборка.Статус+Символы.ПС+"Установил "+Выборка.Ответственный+?(ПустаяСтрока(Выборка.Комментарий), "", Символы.ПС+Выборка.Комментарий);
		Список.Добавить(, Представление);
		
	КонецЦикла;
	
	Возврат Список;
	
КонецФункции

Процедура ЗаписатьЦены(ИдентификаторСтроки, Данные=Неопределено)
	
	Если Данные = Неопределено Тогда
		Данные
	
	Если Данные.Перечень <> 0
		И ЗначениеЗаполнено(Данные.Цена)
		И ЗначениеЗаполнено(Данные.Контрагент) Тогда
		
		Запись = РегистрыСведений.ЗаявкаЦены.СоздатьМенеджерЗаписи();
		Запись.Период              = ТекущаяДата();
		Запись.ИдентификаторСтроки = Данные.ИдентификаторСтроки;
		Запись.Количество          = Данные.Количество;
		Запись.Цена                = Данные.Цена;
		Запись.Перечень            = Данные.Перечень;
		Запись.Контрагент          = Данные.Контрагент;
		Запись.Ответственный       = Пользователь;
		Запись.ИмяКомпьютера       = ИмяКомпьютера();
		
		Запись.Записать();
		
	КонецЕсли;
	
КонецПроцедуры

