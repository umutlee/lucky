export class DateUtils {
  static validateDateFormat(dateStr: string): boolean {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (!regex.test(dateStr)) return false;

    const [year, month, day] = dateStr.split('-').map(Number);
    const date = new Date(year, month - 1, day);
    
    return date.getFullYear() === year &&
           date.getMonth() === month - 1 &&
           date.getDate() === day;
  }

  static validateYearMonth(year: string, month: string): boolean {
    const yearNum = Number(year);
    const monthNum = Number(month);

    return !isNaN(yearNum) && !isNaN(monthNum) &&
           yearNum >= 1900 && yearNum <= 2100 &&
           monthNum >= 1 && monthNum <= 12;
  }

  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  static parseDate(dateStr: string): Date | null {
    if (!this.validateDateFormat(dateStr)) return null;
    return new Date(dateStr);
  }

  static getCurrentDate(): string {
    return this.formatDate(new Date());
  }

  static addDays(dateStr: string, days: number): string | null {
    const date = this.parseDate(dateStr);
    if (!date) return null;
    
    date.setDate(date.getDate() + days);
    return this.formatDate(date);
  }
} 