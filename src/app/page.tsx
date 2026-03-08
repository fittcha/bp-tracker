import DdayCard from '@/components/dashboard/DdayCard'
import WeekProgressBar from '@/components/dashboard/WeekProgressBar'
import TodayStatus from '@/components/dashboard/TodayStatus'
import WeeklySummaryCard from '@/components/dashboard/WeeklySummaryCard'

export default function Home() {
  return (
    <div className="flex flex-col gap-4">
      <DdayCard />
      <WeekProgressBar />
      <TodayStatus />
      <WeeklySummaryCard />
    </div>
  )
}
