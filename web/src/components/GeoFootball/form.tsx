import { Marker, Popup, useMapEvents } from 'react-leaflet'
import { LeafletEvent, Icon, Marker as LeafletMarker } from 'leaflet'
import { useForm } from 'react-hook-form'
import { useState } from 'react'
import { Noto_Color_Emoji } from 'next/font/google'

import type { Station, GroupedStations } from './types'
import Loading from './loading'
import { flag, saveStation } from './slice'

import styles from './index.module.css'
import { useDispatch } from 'react-redux'

const emoji = Noto_Color_Emoji({ weight: '400', subsets: ['emoji'], preload: false })

const pin = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/2684/2684860.png',
	iconSize: [24, 24],
	iconAnchor: [0, 24],
})

interface Properties {
	clusters: GroupedStations,
	setClusters: Function,
}


const MapForm = ({ clusters, setClusters }: Properties) => {
	const countries = Object.keys(clusters)

	const initialStation = {
		name: '',
		country: 'GB',
		time_zone: 'Europe/London',
		latitude: 51.478,
		longitude: 0,
		info_en: '',
	} as Station

	const [station, setStation] = useState(initialStation)
	const [marker, setMarker] = useState(null)

	const {
		register,
		handleSubmit,
		formState: { isSubmitting, errors },
		reset,
		setError,
	} = useForm({
		defaultValues: { ...initialStation },
	});

	useMapEvents({
		dblclick(event) {
			setStation({
				...station,
				latitude: event.latlng.lat,
				longitude: event.latlng.lng,
			})
			marker && (marker as LeafletMarker).openPopup()
		}
	})

	const save = async (data: object | undefined) => {
		const response = await saveStation({
			...data,
			latitude: station.latitude,
			longitude: station.longitude,
		} as Station)
		if (response.ok) {
			marker && (marker as LeafletMarker).closePopup()
			const record = await response.json() as Station
			setStation({ ...initialStation });
			const cluster = clusters[record.country] as Station[]

			setClusters({
				...clusters,
				[record.country]: [...cluster, record],
			})
			reset()
		} else if (response.status == 400) {
			const errors: { [field: string]: string } = await response.json()
			for (const [field, message] of Object.entries(errors)) {
				setError(field as keyof Station, { type: 'custom', message })
			}
		} else {
			const message = await response.text()
			console.error(`Unknown error: ${message}`)
		}

		return response
	}

	const afterAdd = (event: LeafletEvent) => setMarker(event.target)

	return (
		<Marker position={[station.latitude, station.longitude]} icon={pin} eventHandlers={{ add: afterAdd }}>
			<Popup>
				<form id="popup-add-form" className={`${styles.form}`} method="POST" onSubmit={handleSubmit(save)}>
					<h3>Add New Marker</h3>
					<label htmlFor="name">Name:</label>
					<input id="name" type="text" role="textbox" required {...register('name')} />
					<div className={styles.error}>{errors.name?.message}</div>
					<div className={styles.location}>
						<div>
							<label htmlFor="latitude">Latitude:</label>
							<input id="latitude" type="text" name="latitude" value={station.latitude.toFixed(5)} disabled />
						</div>
						<div>
							<label htmlFor="longitude">Longitude:</label>
							<input id="longitude" type="text" name="longitude" value={station.longitude.toFixed(5)} disabled />
						</div>
					</div>
					<div className={styles['country-time']}>
						<div className={styles.country}>
							<label htmlFor="country">Country:</label>
							<select id="country" className={emoji.className} {...register('country')}>
								{countries.map((country: string) =>
									<option className={emoji.className} key={country} value={country}>{flag(country)}</option>)}
							</select>
						</div>
						<div className={styles.time}>
							<label htmlFor="time-zone">Timezone:</label>
							<input id="time-zone" type="text" {...register('time_zone')} />
						</div>
					</div>
					<label htmlFor="info-en">Additional information:</label>
					<input id="info-en" type="text" {...register('info_en')} />
					<button type="submit" disabled={isSubmitting}>
						{isSubmitting ? <Loading text="Saving..." /> : 'Save'}
					</button>
				</form>
			</Popup>
		</Marker>
	)
}

MapForm.displayName = 'MapForm'

export default MapForm
